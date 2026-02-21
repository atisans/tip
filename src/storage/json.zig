const std = @import("std");
const models = @import("../core/models.zig");

pub const default_storage = "./tasks.json";

fn get_storage(config: enum { vault, password, tasks }) void {
    _ = config; // autofix
}

/// Loads all tasks from the JSON storage file.
/// Uses `parseFromSliceLeaky` so all parsed data (including string fields) is owned
/// by the provided allocator. Callers should pass an arena allocator so everything
/// is freed at once when the arena is torn down.
pub fn load_tasks(arena: std.mem.Allocator) ![]models.Task {
    const file = std.fs.cwd().openFile(default_storage, .{ .mode = .read_only }) catch |err| {
        if (err == error.FileNotFound) return &[_]models.Task{};
        return err;
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
    const file = try std.fs.cwd().createFile(default_storage, .{});
    defer file.close();

    const string = try std.json.Stringify.valueAlloc(
        allocator,
        .{ .tasks = tasks },
        .{ .whitespace = .indent_2 },
    );
    defer allocator.free(string);

    _ = try file.write(string);
}
