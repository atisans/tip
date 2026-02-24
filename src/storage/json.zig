const std = @import("std");
const builtin = @import("builtin");
const models = @import("../core/models.zig");

fn get_config_dir(allocator: std.mem.Allocator) ![]u8 {
    return switch (builtin.os.tag) {
        .windows => std.fs.getAppDataDir(allocator, "tip"),
        .macos => std.fs.getAppDataDir(allocator, "tip"),
        .linux, .freebsd, .netbsd, .dragonfly, .openbsd, .solaris, .illumos, .serenity => {
            // TODO: revisit after 0.16+ is out; check for breaking change
            if (std.posix.getenv("XDG_DATA_HOME")) |xdg| {
                if (xdg.len > 0) {
                    return std.fs.path.join(allocator, &[_][]const u8{ xdg, "tip" });
                }
            }

            const home_dir = std.process.getEnvVarOwned(allocator, "HOME") catch |err| switch (err) {
                error.OutOfMemory => |e| return e,
                else => return error.AppDataDirUnavailable,
            };
            defer allocator.free(home_dir);
            return std.fs.path.join(allocator, &[_][]const u8{ home_dir, ".config", "tip" });
        },
        .haiku => std.fs.getAppDataDir(allocator, "tip"),
        else => std.fs.getAppDataDir(allocator, "tip"),
    };
}

fn get_storage(allocator: std.mem.Allocator, @"type": enum { vault, password, tasks }) ![]const u8 {
    const config_dir = try get_config_dir(allocator);
    std.fs.cwd().makePath(config_dir) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };

    const filename = switch (@"type") {
        .tasks => "tasks.json",
        .vault => "vault.json",
        .password => "password.json",
    };
    return try std.fs.path.join(allocator, &[_][]const u8{ config_dir, filename });
}

/// Loads all tasks from the JSON storage file.
/// Uses `parseFromSliceLeaky` so all parsed data (including string fields) is owned
/// by the provided allocator. Callers should pass an arena allocator so everything
/// is freed at once when the arena is torn down.
pub fn load_tasks(arena: std.mem.Allocator) ![]models.Task {
    const storage = try get_storage(arena, .tasks);
    defer arena.free(storage);

    const file = std.fs.cwd().openFile(storage, .{ .mode = .read_only }) catch |err| {
        return switch (err) {
            error.FileNotFound => &[_]models.Task{},
            else => err,
        };
    };
    defer file.close();

    const stat = try file.stat();
    if (stat.size == 0) return &[_]models.Task{};

    const contents = try arena.alloc(u8, stat.size);
    _ = try file.read(contents);

    const parsed = try std.json.parseFromSliceLeaky(struct { tasks: []models.Task }, arena, contents, .{});

    return parsed.tasks;
}

/// Serializes the given tasks to JSON and writes them to the storage file,
/// replacing any existing content.
pub fn save_tasks(allocator: std.mem.Allocator, tasks: []const models.Task) !void {
    const storage = try get_storage(allocator, .tasks);
    defer allocator.free(storage);

    const file = try std.fs.cwd().createFile(storage, .{});
    defer file.close();

    const string = try std.json.Stringify.valueAlloc(
        allocator,
        .{ .tasks = tasks },
        .{ .whitespace = .indent_2 },
    );
    defer allocator.free(string);

    _ = try file.write(string);
}
