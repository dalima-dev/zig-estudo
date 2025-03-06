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

const clear = Example{
    .name = "clear",
    .path = "clear.zig",
    .run = "clear",
    .description = "Clear example",
};

const primitives = Example{
    .name = "primitives",
    .path = "primitives.zig",
    .run = "primitives",
    .description = "Primitives example",
};

const lines = Example{
    .name = "lines",
    .path = "lines.zig",
    .run = "lines",
    .description = "Lines example",
};

const points = Example{
    .name = "points",
    .path = "points.zig",
    .run = "points",
    .description = "Points example",
};

const debug_text = Example{
    .name = "debug-text",
    .path = "debug-text.zig",
    .run = "debug-text",
    .description = "Debug text example",
};

const simple_playback = Example{
    .name = "simple-playback",
    .path = "simple-playback.zig",
    .run = "simple-playback",
    .description = "Simple playback example",
};

const examples = [_]Example{ window, clear, primitives, lines, points, debug_text, simple_playback };

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
