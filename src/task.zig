const std = @import("std");

const item = struct {
    id: u32,
    task: []const u8,
    done: bool,
    created_at: i64,
    completed_at: ?i64,
};

pub const Task = struct {
    allocator: std.mem.Allocator,
    list: std.ArrayList(item),

    pub fn init(allocator: std.mem.Allocator) Task {
        return .{
            .allocator = allocator,
            .list = .empty,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.list.deinit(self.allocator);
    }

    pub fn add(self: *@This(), task: []const u8) !void {
        const new_task: item = .{
            .done = false,
            .id = @intCast(self.list.items.len + 1),
            .task = task,
            .created_at = std.time.timestamp(),
            .completed_at = null,
        };

        try self.list.append(self.allocator, new_task);
    }

    pub fn complete(self: *@This(), id: usize) !void {
        for (self.list.items) |*itm| {
            if (itm.id == id) {
                itm.done = true;
                itm.completed_at = std.time.timestamp();
                return;
            }
        }

        std.debug.print("Item {d} does not exist!\n", .{id});
        return error.InvalidItem;
    }

    pub fn delete(self: *@This(), task_id: usize) !void {
        if (task_id == 0) return error.InvalidItem;

        for (self.list.items, 0..) |value, idx| {
            if (value.id == task_id) {
                _ = self.list.orderedRemove(idx);
                return;
            }
        }

        return error.InvalidItem;
    }

    pub fn save_to_file(self: *@This(), filepath: []const u8) !void {
        const file = try std.fs.cwd().createFile(filepath, .{});
        defer file.close();

        const string = try std.json.Stringify.valueAlloc(
            self.allocator,
            .{ .tasks = self.list.items },
            .{ .whitespace = .indent_2 },
        );
        defer self.allocator.free(string);

        try file.writeAll(string);
    }

    pub fn get_file(self: *@This(), filepath: []const u8) ![]const u8 {
        const file = try std.fs.cwd().openFile(filepath, .{});
        defer file.close();

        const stat = try file.stat();

        const contents = try self.allocator.alloc(u8, stat.size);
        defer self.allocator.free(contents);

        _ = try file.read(contents);

        // const parsed = try std.json.parseFromSlice(struct {tasks:[]item}, allocator, s: []const u8, options: ParseOptions)
        return contents;
    }
};

test "add task" {
    const allocator = std.testing.allocator;
    var tasks = Task.init(allocator);
    defer tasks.deinit();
    try tasks.add("New Task");

    try std.testing.expect(tasks.list.items.len == 1);
}

test "mark complete" {
    const allocator = std.testing.allocator;
    var tasks = Task.init(allocator);
    defer tasks.deinit();

    const task_name = "New Task";

    try tasks.add(task_name);

    try std.testing.expectEqualStrings(tasks.list.items[0].task, task_name);

    try std.testing.expect(tasks.list.items[0].done == false);

    try tasks.complete(1);

    try std.testing.expect(tasks.list.items[0].done == true);
}

test "delete task" {
    const allocator = std.testing.allocator;
    var tasks = Task.init(allocator);
    defer tasks.deinit();

    const new_tasks = [_][]const u8{ "New Task 1", "New Task 2", "New Task 3" };

    for (new_tasks) |tsk| {
        try tasks.add(tsk);
    }

    try std.testing.expectEqualStrings(tasks.list.items[0].task, new_tasks[0]);

    try std.testing.expectError(error.InvalidItem, tasks.delete(0));

    try tasks.delete(3);
    try std.testing.expect(tasks.list.items.len == new_tasks.len - 1);

    try std.testing.expectEqualStrings(tasks.list.items[1].task, new_tasks[1]);
}

test "save to file" {
    const allocator = std.testing.allocator;
    var tasks = Task.init(allocator);
    defer tasks.deinit();

    const new_tasks = [_][]const u8{ "New Task 1", "New Task 2", "New Task 3" };

    for (new_tasks) |tsk| {
        try tasks.add(tsk);
    }

    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    const current_dir = try tmp_dir.dir.realpathAlloc(allocator, ".");
    defer allocator.free(current_dir);

    const filepath = try std.mem.concat(allocator, u8, &.{ current_dir, "/test.json" });
    defer allocator.free(filepath);
    try tasks.save_to_file(filepath);
}

test "get file" {
    const allocator = std.testing.allocator;
    var tasks = Task.init(allocator);
    defer tasks.deinit();

    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    const current_dir = try tmp_dir.dir.realpathAlloc(allocator, ".");
    defer allocator.free(current_dir);

    const filepath = try std.mem.concat(allocator, u8, &.{ current_dir, "/input.json" });
    defer allocator.free(filepath);

    try std.testing.expectError(error.FileNotFound, tasks.get_file(filepath));

    try tasks.add("New task");
    try tasks.save_to_file(filepath);

    _ = try tasks.get_file(filepath);
}
