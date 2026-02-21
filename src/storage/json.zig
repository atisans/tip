const std = @import("std");
const models = @import("../core/models.zig");

pub const default_storage = "./tasks.json";

fn get_storage(config: enum { vault, password, tasks }) void {
    _ = config; // autofix
}

pub fn load_tasks(arena: std.mem.Allocator) ![]models.Task {
    const file = try std.fs.cwd().createFile(default_storage, .{ .read = true, .truncate = false });
    defer file.close();

    const stat = try file.stat();
    const contents = try arena.alloc(u8, stat.size);

    _ = try file.read(contents);

    const parsed = try std.json.parseFromSliceLeaky(struct { tasks: []models.Task }, arena, contents, .{});
    const tasks = try arena.dupe(models.Task, parsed.tasks);

    return tasks;
}

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
