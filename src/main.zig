const std = @import("std");
const version = @import("version").version;
const flags = @import("flags");
const task = @import("core/task.zig");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: tip <global-flags> <command> <subcommand> [args] [flags]\n", .{});
        return;
    }

    const Args = union(enum) {
        task: task.TaskArgs,
        version: struct {},
    };
    const parsed = flags.parse(args, Args) catch |err| {
        return switch (err) {
            error.UnknownSubcommand => {
                std.debug.print("Usage: tip <global-flags> <command> <subcommand> [args] [flags]\n", .{});
                std.debug.print("Run 'tip --help' for more information.\n", .{});
            },
            else => {},
        };
    };

    switch (parsed) {
        .task => |t| task.execute_commands(t),
        .version => std.debug.print("tip {s}", .{version}),
    }
}
