const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const test_module = b.addModule("zig_collections_test", .{
        .root_source_file = b.path("tests.zig"),
        .target = target,
        .optimize = optimize,
    });

    const integration_tests = b.addTest(.{ .root_module = test_module });

    const zig_collections = b.dependency("zig_collections", .{});
    integration_tests.root_module.addImport("zig_collections", zig_collections.module("zig_collections"));

    const run_lib_unit_tests = b.addRunArtifact(integration_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
