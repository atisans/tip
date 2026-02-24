const std = @import("std");

pub fn uuid(allocator: std.mem.Allocator) ![]u8 {
    // ---- head: Date.now().toString(36)
    const millis = std.time.milliTimestamp();

    var head_buf: [32]u8 = undefined;
    const head = try std.fmt.bufPrint(&head_buf, "{x}", .{millis});

    // ---- tail: Math.random().toString(36).substr(2)
    var prng = std.Random.DefaultPrng.init(@as(u64, @intCast(std.time.nanoTimestamp())));
    const rnd = prng.random().int(u64);

    var tail_buf: [32]u8 = undefined;
    const tail = try std.fmt.bufPrint(&tail_buf, "{x}", .{rnd});

    // ---- concatenate head + tail
    return try std.mem.concat(allocator, u8, &.{ head, tail });
}
