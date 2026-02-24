const std = @import("std");
const app = @import("version");
const flags = @import("flags");
const task = @import("core/task.zig");

const Args = struct {
    version: bool = false,
    command: ?union(enum) {
        task: task.TaskArgs,
    } = null,

    pub const help =
        \\Tip - Password and Task Manager
        \\
        \\Usage:
        \\  tip <command> [args] [flags]
        \\
        \\Options:
        \\  -h, --help            Show help
        \\  -v, --version         Show version
        \\
        \\Commands:
        \\  task                   Task management
        // \\  password               Password management
        // \\  vault                  Vault management
        // \\  config                 Configuration
        // \\  auth                   Authentication
        // \\  sync                   Synchronization
        // \\  export                 Export data
        // \\  import                 Import data
        \\
        \\Run 'tip <command> --help' for more information on a command.
        \\
    ;
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("{s}\n", .{Args.help});
        return;
    }

    const parsed = flags.parse(allocator, args, Args) catch |err| {
        return switch (err) {
            else => std.debug.print("{any}\n", .{err}),
        };
    };

    if (parsed.version) {
        std.debug.print("{s}\n", .{app.version});
        return;
    }

    if (parsed.command) |command| {
        switch (command) {
            .task => |t| task.execute_commands(t),
        }
    }
}
