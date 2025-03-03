const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "image_filter",
        .root_source_file = b.path("src/image_filter.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();
    // Link to libspng library:
    exe.linkSystemLibrary("spng");
    b.installArtifact(exe);
}
