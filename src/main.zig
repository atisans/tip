const std = @import("std");
const flags = @import("flags");
const task = @import("task.zig");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const Args = union(enum) {
        task: task.TaskArgs,
    };
    const parsed = try flags.parse(args, Args);

    switch (parsed) {
        .task => |t| task.execute_commands(t),
    }
}
