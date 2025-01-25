const std = @import("std");
const ExecutableOptions = std.Build.ExecutableOptions;

pub const Exercise = struct {
    name: []const u8,
    file_name: []const u8,
    run: []const u8,
    description: []const u8,
};

pub const exercises = [_]Exercise{};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    inline for (exercises) |exercise| {
        const executable = b.addExecutable(.{
            .name = exercise.name,
            .root_source_file = b.path(exercise.file_name),
            .target = target,
            .optimize = optimize,
        });

        b.installArtifact(executable);

        const run_exercise = b.addRunArtifact(executable);
        run_exercise.step.dependOn(b.getInstallStep());

        const run_exercise_step = b.step(exercise.run, exercise.description);
        run_exercise_step.dependOn(&run_exercise.step);
    }
}
