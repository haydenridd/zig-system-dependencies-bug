const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Static library that depends on our "sys_lib" pre-compiled system library
    const static_lib = b.addStaticLibrary(.{ .name = "staticlib", .target = target, .optimize = optimize });
    static_lib.addCSourceFiles(.{
        .files = &.{"static_library/staticlib.c"},
    });
    static_lib.addIncludePath(b.path("static_library"));
    static_lib.installHeadersDirectory(b.path("static_library"), "staticlib", .{});
    static_lib.addSystemIncludePath(.{ .cwd_relative = "/home/hayden/Documents/zig/system_includes_bug/sys_lib_folder/include" });
    static_lib.addLibraryPath(.{ .cwd_relative = "/home/hayden/Documents/zig/system_includes_bug/sys_lib_folder/lib" });
    static_lib.linkSystemLibrary("sys_lib");
    b.installArtifact(static_lib);

    // Exe that links against our static library
    const exe = b.addExecutable(.{ .name = "main", .target = target, .optimize = optimize, .link_libc = true });
    exe.addCSourceFiles(.{ .files = &.{
        "src/main.c",
    } });
    exe.linkLibrary(static_lib);

    // Required for "exe" to be able to find system library path for libsys_lib.a:
    exe.addLibraryPath(.{ .cwd_relative = "/home/hayden/Documents/zig/system_includes_bug/sys_lib_folder/lib" });

    // Required for "exe" to be able to find system include path for sys_lib.h:
    exe.addSystemIncludePath(.{ .cwd_relative = "/home/hayden/Documents/zig/system_includes_bug/sys_lib_folder/include" });

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
