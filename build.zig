const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "tip",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    b.step("run", "Run the app").dependOn(&run_cmd.step);

    // Generate test runner that imports all .zig files under src/
    const auto_test_file = generate_test_runner(b, "src") catch |err| {
        std.log.err("Failed to generate test runner: {}", .{err});
        return;
    };

    const all_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = auto_test_file,
            .target = target,
            .optimize = optimize,
        }),
    });
    b.step("test", "Run all tests").dependOn(&b.addRunArtifact(all_tests).step);
}

fn generate_test_runner(b: *std.Build, src_dir: []const u8) !std.Build.LazyPath {
    var files: std.ArrayList([]const u8) = .empty;
    defer {
        for (files.items) |f| b.allocator.free(f);
        files.deinit(b.allocator);
    }

    try collect_files(b, src_dir, b.allocator, &files);

    var content: std.ArrayList(u8) = .empty;
    defer content.deinit(b.allocator);

    const w = content.writer(b.allocator);
    try w.writeAll("// Auto-generated - do not edit\n");
    try w.writeAll("test {\n");
    for (files.items) |f| {
        if (std.mem.containsAtLeast(u8, f, 1, "auto_test_runner")) continue;
        try w.print("    _ = @import(\"{s}\");\n", .{f});
    }
    try w.writeAll("}\n");

    const root = b.build_root.path orelse ".";
    const path = try std.fs.path.join(b.allocator, &.{ root, "auto_test_runner.zig" });
    defer b.allocator.free(path);

    try std.fs.cwd().writeFile(.{ .sub_path = path, .data = content.items });
    return b.path("auto_test_runner.zig");
}

fn collect_files(b: *std.Build, dir: []const u8, gpa: std.mem.Allocator, files: *std.ArrayList([]const u8)) !void {
    const root = b.build_root.path orelse ".";
    const full = try std.fs.path.join(gpa, &.{ root, dir });
    defer gpa.free(full);

    var d = std.fs.openDirAbsolute(full, .{ .iterate = true }) catch |e| {
        if (e == error.FileNotFound) return;
        return e;
    };
    defer d.close();

    var it = d.iterate();
    while (try it.next()) |e| {
        if (e.kind == .file and std.mem.endsWith(u8, e.name, ".zig")) {
            if (e.name[0] == '.') continue;
            const p = try std.fs.path.join(gpa, &.{ dir, e.name });
            try files.append(gpa, p);
        } else if (e.kind == .directory) {
            if (e.name[0] == '.' or std.mem.startsWith(u8, e.name, "zig-cache") or std.mem.startsWith(u8, e.name, "zig-pkg")) continue;
            const sub = try std.fs.path.join(gpa, &.{ dir, e.name });
            defer gpa.free(sub);
            try collect_files(b, sub, gpa, files);
        }
    }
}
