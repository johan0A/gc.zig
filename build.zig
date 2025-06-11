const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_module = b.addModule("gc", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const bdwgc_dep = b.dependency("bdwgc", .{
        .target = target,
        .optimize = optimize,
    });
    const gc_artifact = bdwgc_dep.artifact("gc");
    root_module.linkLibrary(gc_artifact);

    const translate_c = b.addTranslateC(.{
        .root_source_file = gc_artifact.getEmittedIncludeTree().path(b, "gc.h"),
        .target = target,
        .optimize = optimize,
    });
    root_module.addImport("c", translate_c.createModule());

    {
        const lib_unit_tests = b.addTest(.{ .root_module = root_module });
        const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_lib_unit_tests.step);
    }

    {
        const tests_check = b.addTest(.{ .root_module = root_module });
        const check = b.step("check", "Check if tests compile");
        check.dependOn(&tests_check.step);
    }
}
