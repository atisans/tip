const std = @import("std");
const models = @import("models.zig");
const storage = @import("../storage/json.zig");
const generate = @import("../utils/generate.zig");

pub const TaskArgs = struct {
    list: bool = false,
    subcommand: ?union(enum) {
        add: struct {
            name: []const u8,
        },
    } = null,

    pub const help =
        \\Task Management Commands
        \\
        \\Usage:
        \\  tip task <subcommand> [args] [flags]
        \\
        \\Options:
        \\  --list                        List all tasks
        \\
        \\Commands:
        \\  add --name=<name>              Add new task
        \\
        \\Examples:
        \\  tip task --list
        \\  tip task add --name="Review code"
        \\
    ;
};

/// Dispatches the appropriate task operation based on the parsed CLI arguments.
pub fn execute_commands(T: TaskArgs) void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var dir = storage.open_config_dir(allocator) catch {
        std.debug.print("Failed to open config directory\n", .{});
        return;
    };
    defer dir.close();

    if (T.list) {
        list_task(allocator, dir) catch {};
        return;
    }

    if (T.subcommand) |subcommand| {
        switch (subcommand) {
            .add => |add| add_task(allocator, add.name, dir) catch {
                std.debug.print("Failed to add task\n", .{});
                return;
            },
        }
    } else {
        std.debug.print("{s}\n", .{TaskArgs.help});
    }
}

/// Creates a new task with the given title and persists it to storage.
fn add_task(allocator: std.mem.Allocator, title: []const u8, dir: std.fs.Dir) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const existing = storage.load_tasks(arena.allocator(), dir) catch &[_]models.Task{};

    var tasks: std.ArrayList(models.Task) = .empty;
    defer tasks.deinit(allocator);
    for (existing) |task| {
        tasks.append(allocator, task) catch continue;
    }

    const id = try generate.uuid(allocator);
    defer allocator.free(id);
    try tasks.append(allocator, .{
        .status = .pending,
        .id = id[0..],
        .title = title[0..],
        .created_at = std.time.timestamp(),
    });
    std.debug.print("Adding task: {s}\n", .{title});

    try storage.save_tasks(arena.allocator(), dir, tasks.items);
}

/// Loads and prints all tasks from storage.
fn list_task(allocator: std.mem.Allocator, dir: std.fs.Dir) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const tasks = storage.load_tasks(arena.allocator(), dir) catch |err| {
        switch (err) {
            error.FileNotFound => {
                std.debug.print("No tasks\n", .{});
                return;
            },
            else => return,
        }
    };
    std.debug.print("({d}) Tasks:\n", .{tasks.len});

    for (tasks) |task| {
        if (task.status == .completed) {
            std.debug.print("    [x]: {s}\n", .{task.title});
        } else {
            std.debug.print("    [ ]: {s}\n", .{task.title});
        }
    }
}

/// Marks the task matching `task_id` as completed. Returns `error.InvalidItem`
/// if no task with that id exists.
fn mark_complete(allocator: std.mem.Allocator, task_id: []const u8, dir: std.fs.Dir) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit(); // frees everything at once

    const tasks = storage.load_tasks(arena.allocator(), dir) catch {
        return;
    };

    for (tasks) |*task| {
        if (std.mem.eql(u8, task.id, task_id)) {
            task.status = .completed;
            task.updated_at = std.time.timestamp();
            task.completed_at = std.time.timestamp();
            try storage.save_tasks(arena.allocator(), dir, tasks);
            return;
        }
    }

    std.debug.print("Item {s} does not exist!\n", .{task_id});
    return error.InvalidItem;
}

/// Removes the task matching `task_id` from storage. Returns `error.InvalidItem`
/// if no task with that id exists.
fn delete_task(allocator: std.mem.Allocator, task_id: []const u8, dir: std.fs.Dir) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const arena_alloc = arena.allocator();

    const tasks = storage.load_tasks(arena_alloc, dir) catch {
        return;
    };

    var remaining: std.ArrayList(models.Task) = .empty;
    var found = false;

    for (tasks) |task| {
        if (std.mem.eql(u8, task.id, task_id)) {
            found = true;
        } else {
            try remaining.append(arena_alloc, task);
        }
    }

    if (!found) return error.InvalidItem;

    try storage.save_tasks(arena_alloc, dir, remaining.items);
}

test "add and list tasks" {
    const allocator = std.testing.allocator;

    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    try add_task(allocator, "Test Task", tmp_dir.dir);

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const tasks = try storage.load_tasks(arena.allocator(), tmp_dir.dir);
    try std.testing.expectEqual(tasks.len, 1);
    try std.testing.expectEqualStrings(tasks[0].title, "Test Task");
    try std.testing.expectEqual(tasks[0].status, .pending);
    try std.testing.expect(tasks[0].id.len > 0);
    try std.testing.expect(tasks[0].created_at > 0);
}

test "delete task" {
    const allocator = std.testing.allocator;

    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    try add_task(allocator, "To Delete", tmp_dir.dir);

    const task_id = blk: {
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();
        const tasks = try storage.load_tasks(arena.allocator(), tmp_dir.dir);
        try std.testing.expectEqual(tasks.len, 1);
        break :blk try allocator.dupe(u8, tasks[0].id);
    };
    defer allocator.free(task_id);

    try delete_task(allocator, task_id, tmp_dir.dir);

    {
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();
        const tasks = try storage.load_tasks(arena.allocator(), tmp_dir.dir);
        try std.testing.expectEqual(tasks.len, 0);
    }
}

test "delete nonexistent task returns error" {
    const allocator = std.testing.allocator;

    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    try std.testing.expectError(error.InvalidItem, delete_task(allocator, "999", tmp_dir.dir));
}

test "list task with no file" {
    const allocator = std.testing.allocator;

    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    // Should not error — just prints "No tasks"
    try list_task(allocator, tmp_dir.dir);
}

test "mark_complete sets status and timestamps" {
    const allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    try add_task(allocator, "Complete Me", tmp_dir.dir);

    const tasks = try storage.load_tasks(arena.allocator(), tmp_dir.dir);
    try mark_complete(allocator, tasks[0].id, tmp_dir.dir);

    const updated = try storage.load_tasks(arena.allocator(), tmp_dir.dir);
    try std.testing.expectEqual(updated[0].status, .completed);
    try std.testing.expect(updated[0].updated_at != null);
    try std.testing.expect(updated[0].completed_at != null);
}

test "mark_complete nonexistent task returns error" {
    const allocator = std.testing.allocator;

    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    try add_task(allocator, "Some Task", tmp_dir.dir);

    try std.testing.expectError(error.InvalidItem, mark_complete(allocator, "nonexistent-id", tmp_dir.dir));
}
