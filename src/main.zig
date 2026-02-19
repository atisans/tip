const std = @import("std");
const Task = @import("task.zig").Task;

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}
