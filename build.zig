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

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    // A run step that will run the exe test executable.
    const run_exe_tests = b.addRunArtifact(exe_tests);

    // Generate test runner file
    const auto_test_file = generate_test_runner(b, "src") catch |err| {
        std.log.err("Failed to generate test runner: {}", .{err});
        return;
    };

    // Test runner that includes all module tests
    const all_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = auto_test_file,
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_auto_tests = b.addRunArtifact(all_tests);

    const cleanup = b.allocator.create(std.Build.Step) catch @panic("OOM");
    cleanup.* = std.Build.Step.init(.{
        .id = .custom,
        .name = "cleanup test runner",
        .owner = b,
        .makeFn = cleanup_test_runner,
    });

    cleanup.dependOn(&run_auto_tests.step);

    const test_step = b.step("test", "Run tests with cleanup");
    test_step.dependOn(&run_exe_tests.step);
    test_step.dependOn(cleanup);
}

fn cleanup_test_runner() !void {
    std.fs.cwd().deleteFile("auto_test_runner.zig") catch |err| {
        if (err != error.FileNotFound) {
            std.log.warn("Failed to cleanup test runner: {}", .{err});
        }
    };
}

fn generate_test_runner(b: *std.Build, src_dir: []const u8) !std.Build.LazyPath {
    var files: std.ArrayList([]const u8) = .{};
    defer {
        for (files.items) |f| b.allocator.free(f);
        files.deinit(b.allocator);
    }

    try collect_files(b, src_dir, b.allocator, &files);

    var content: std.ArrayList(u8) = .{};
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
            if (e.name[0] == '.' or std.mem.eql(u8, e.name, "tests.zig")) continue;
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
