const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sys_lib = b.addStaticLibrary(.{ .name = "sys_lib", .target = target, .optimize = optimize });
    sys_lib.addCSourceFiles(.{ .files = &.{
        "src/sys_lib.c",
    } });
    sys_lib.addIncludePath(b.path("src"));
    sys_lib.installHeadersDirectory(b.path("src"), "", .{});
    b.installArtifact(sys_lib);
}
