const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = blk: {
        const module = b.addModule("zig_gc", .{
            .root_source_file = b.path("src/module.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });

        if (target.result.isDarwinLibC()) module.linkFramework("Foundation", .{});
        module.addIncludePath(b.path("bdwgc/include"));

        const c_source_files = [_][]const u8{
            "allchblk.c",
            "alloc.c",
            "blacklst.c",
            "dbg_mlc.c",
            "dyn_load.c",
            "finalize.c",
            "headers.c",
            "mach_dep.c",
            "malloc.c",
            "mallocx.c",
            "mark.c",
            "mark_rts.c",
            "misc.c",
            "new_hblk.c",
            "obj_map.c",
            "os_dep.c",
            "ptr_chck.c",
            "reclaim.c",
            "typd_mlc.c",
        };

        inline for (c_source_files) |src| {
            module.addCSourceFile(.{
                .file = b.path("bdwgc/" ++ src),
            });
        }
        break :blk module;
    };

    {
        const module_unit_tests = b.addTest(.{
            // .root_source_file = b.path("src/module.zig"),
            .target = target,
            .optimize = optimize,
            .root_module = module,
        });

        const run_lib_unit_tests = b.addRunArtifact(module_unit_tests);

        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_lib_unit_tests.step);
    }
}
