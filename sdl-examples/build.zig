const std = @import("std");

pub const Example = struct {
    name: []const u8,
    path: []const u8,
    run: []const u8,
    description: []const u8,
};

const window = Example{
    .name = "window",
    .path = "window.zig",
    .run = "window",
    .description = "Window example",
};

const examples = [_]Example{window};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sdl_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl_lib = sdl_dep.artifact("SDL3");

    inline for (examples) |example| {
        const exe = b.addExecutable(.{
            .name = example.name,
            .root_source_file = b.path(example.path),
            .target = target,
            .optimize = optimize,
        });

        exe.root_module.linkLibrary(sdl_lib);
        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        const run_step = b.step(example.run, example.description);
        run_step.dependOn(&run_cmd.step);
    }
}
