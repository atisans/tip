const std = @import("std");
const models = @import("models.zig");
const storage = @import("../storage/json.zig");

pub const TaskArgs = struct {
    add: ?[]const u8 = null,
    list: bool = false,
};

/// Dispatches the appropriate task operation based on the parsed CLI arguments.
pub fn execute_commands(T: TaskArgs) void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    if (T.add) |value| {
        add_task(allocator, value) catch {
            std.debug.print("Failed to add task\n", .{});
            return;
        };
    } else if (T.list) {
        list_task(allocator) catch {};
    }
}

/// Creates a new task with the given title and persists it to storage.
fn add_task(allocator: std.mem.Allocator, title: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const existing = storage.load_tasks(arena.allocator()) catch &[_]models.Task{};

    var tasks: std.ArrayList(models.Task) = .empty;
    defer tasks.deinit(allocator);
    for (existing) |task| {
        tasks.append(allocator, task) catch continue;
    }

    try tasks.append(allocator, .{
        .status = .pending,
        .id = "1",
        .title = title[0..],
        .created_at = std.time.timestamp(),
    });
    std.debug.print("Adding task: {s}\n", .{title});

    try storage.save_tasks(arena.allocator(), tasks.items);
}

/// Loads and prints all tasks from storage.
fn list_task(allocator: std.mem.Allocator) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const tasks = storage.load_tasks(arena.allocator()) catch |err| {
        switch (err) {
            error.FileNotFound => {
                std.debug.print("No tasks\n", .{});
                return;
            },
            else => return,
        }
    };
    std.debug.print("Len: {d}\n", .{tasks.len});

    for (tasks) |task| {
        std.debug.print("{s}: {s}\n", .{ task.id, task.title });
    }
}

/// Marks the task matching `task_id` as completed. Returns `error.InvalidItem`
/// if no task with that id exists.
fn mark_complete(allocator: std.mem.Allocator, task_id: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit(); // frees everything at once

    const tasks = storage.load_tasks(arena.allocator()) catch {
        return;
    };

    for (tasks) |*task| {
        if (task.id == task_id) {
            task.status = .completed;
            task.updated_at = std.time.timestamp();
            task.completed_at = std.time.timestamp();
            return;
        }
    }

    std.debug.print("Item {s} does not exist!\n", .{task_id});
    return error.InvalidItem;
}

/// Removes the task matching `task_id` from storage. Returns `error.InvalidItem`
/// if no task with that id exists.
fn delete_task(allocator: std.mem.Allocator, task_id: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const arena_alloc = arena.allocator();

    const tasks = storage.load_tasks(arena_alloc) catch {
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

    try storage.save_tasks(arena_alloc, remaining.items);
}

test "add and list tasks" {
    const allocator = std.testing.allocator;

    var orig_cwd = std.fs.cwd().openDir(".", .{}) catch return;
    defer orig_cwd.close();
    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();
    tmp_dir.dir.setAsCwd() catch return;
    defer orig_cwd.setAsCwd() catch {};

    try add_task(allocator, "Test Task");

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const tasks = try storage.load_tasks(arena.allocator());
    try std.testing.expect(tasks.len == 1);
    try std.testing.expectEqualStrings(tasks[0].title, "Test Task");
}

test "delete task" {
    const allocator = std.testing.allocator;

    var orig_cwd = std.fs.cwd().openDir(".", .{}) catch return;
    defer orig_cwd.close();
    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();
    tmp_dir.dir.setAsCwd() catch return;
    defer orig_cwd.setAsCwd() catch {};

    try add_task(allocator, "To Delete");

    // Verify it exists
    {
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();
        const tasks = try storage.load_tasks(arena.allocator());
        try std.testing.expect(tasks.len == 1);
    }

    try delete_task(allocator, "1");

    // Verify it's gone
    {
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();
        const tasks = try storage.load_tasks(arena.allocator());
        try std.testing.expect(tasks.len == 0);
    }
}

test "delete nonexistent task returns error" {
    const allocator = std.testing.allocator;

    var orig_cwd = std.fs.cwd().openDir(".", .{}) catch return;
    defer orig_cwd.close();
    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();
    tmp_dir.dir.setAsCwd() catch return;
    defer orig_cwd.setAsCwd() catch {};

    try add_task(allocator, "Some Task");

    try std.testing.expectError(error.InvalidItem, delete_task(allocator, "999"));
}

test "list task with no file" {
    const allocator = std.testing.allocator;

    var orig_cwd = std.fs.cwd().openDir(".", .{}) catch return;
    defer orig_cwd.close();
    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();
    tmp_dir.dir.setAsCwd() catch return;
    defer orig_cwd.setAsCwd() catch {};

    // Should not error — just prints "No tasks"
    try list_task(allocator);
}
