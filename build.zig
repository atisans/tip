const std = @import("std");

fn generate_version(b: *std.Build) std.Build.LazyPath {
    const project_root = b.build_root.path orelse ".";
    const zon_path = std.fs.path.join(b.allocator, &.{ project_root, "build.zig.zon" }) catch @panic("OOM");
    defer b.allocator.free(zon_path);

    const zon_file = std.fs.openFileAbsolute(zon_path, .{}) catch @panic("Failed to open build.zig.zon");
    defer zon_file.close();

    const zon_content = zon_file.readToEndAlloc(b.allocator, std.math.maxInt(usize)) catch @panic("Failed to read build.zig.zon");
    defer b.allocator.free(zon_content);

    var version: []const u8 = "0.0.0";
    var lines = std.mem.splitScalar(u8, zon_content, '\n');
    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, std.mem.trim(u8, line, " "), ".version =")) {
            const quote_start = std.mem.indexOf(u8, line, "\"").?;
            const quote_end = std.mem.lastIndexOf(u8, line, "\"").?;
            version = line[quote_start + 1 .. quote_end];
            break;
        }
    }

    const version_content = std.fmt.allocPrint(b.allocator, "pub const version = \"{s}\";\n", .{version}) catch @panic("OOM");

    const wf = b.addWriteFiles();
    return wf.add("version.zig", version_content);
}

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

    const flags = b.dependency("flags", .{});
    exe.root_module.addImport("flags", flags.module("flags"));
    exe.root_module.addImport("version", b.createModule(.{
        .root_source_file = generate_version(b),
    }));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    b.step("run", "Run the app").dependOn(&run_cmd.step);

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

/// Generate test runner in build cache (no disk file to clean up)
fn generate_test_runner(b: *std.Build, src_dir: []const u8) !std.Build.LazyPath {
    const files = try collect_files(b, src_dir);

    var content: std.ArrayList(u8) = .empty;
    defer content.deinit(b.allocator);

    const w = content.writer(b.allocator);
    try w.writeAll("// Auto-generated - do not edit\ntest {\n");
    for (files) |f| {
        try w.print("    _ = @import(\"{s}\");\n", .{f});
    }
    try w.writeAll("}\n");

    const wf = b.addWriteFiles();
    _ = wf.addCopyDirectory(b.path(src_dir), src_dir, .{});
    return wf.add("auto_test_runner.zig", content.items);
}

fn collect_files(b: *std.Build, dir: []const u8) ![]const []const u8 {
    const gpa = b.allocator;
    var files: std.ArrayList([]const u8) = .empty;

    var dirs_to_visit: std.ArrayList([]const u8) = .empty;
    defer dirs_to_visit.deinit(gpa);
    try dirs_to_visit.append(gpa, dir);

    while (dirs_to_visit.items.len > 0) {
        const current = dirs_to_visit.orderedRemove(0);
        const root = b.build_root.path orelse ".";
        const full = try std.fs.path.join(gpa, &.{ root, current });
        defer gpa.free(full);

        var d = std.fs.openDirAbsolute(full, .{ .iterate = true }) catch |e| {
            switch (e) {
                error.FileNotFound => continue,
                else => return e,
            }
        };
        defer d.close();

        var it = d.iterate();
        while (try it.next()) |e| {
            if (e.name[0] == '.') continue;
            if (e.kind == .file and std.mem.endsWith(u8, e.name, ".zig")) {
                try files.append(gpa, try std.fs.path.join(gpa, &.{ current, e.name }));
            } else if (e.kind == .directory and
                !std.mem.startsWith(u8, e.name, "zig-cache") and
                !std.mem.startsWith(u8, e.name, "zig-pkg"))
            {
                try dirs_to_visit.append(gpa, try std.fs.path.join(gpa, &.{ current, e.name }));
            }
        }
    }

    return files.items;
}
