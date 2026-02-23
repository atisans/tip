const std = @import("std");
const app = @import("version");
const flags = @import("flags");
const task = @import("core/task.zig");

const usage_example =
    \\ Usage:
    \\    tip <global-flags> <command> <subcommand> [args] [flags]
    \\    Run 'tip --help' for more information.
;

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("{s}\n", .{usage_example});
        return;
    }

    const Args = struct {
        version: bool = false,
        command: ?union(enum) {
            task: task.TaskArgs,
        } = null,

        pub const help = usage_example;
    };
    const parsed = flags.parse(allocator, args, Args) catch |err| {
        return switch (err) {
            else => std.debug.print("{any}", .{err}),
        };
    };

    if (parsed.version) {
        std.debug.print("tip: {s}\n", .{app.version});
    }

    if (parsed.command) |command| {
        switch (command) {
            .task => |t| task.execute_commands(t),
        }
    }
}
