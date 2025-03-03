const std = @import("std");
const ExecutableOptions = std.Build.ExecutableOptions;

pub const Exercise = struct {
    name: []const u8,
    file_name: []const u8,
    run: []const u8,
    description: []const u8,
};

const project_1 = Exercise{
    .name = "project-1",
    .file_name = "src/project-1.zig",
    .run = "project-1",
    .description = "https://pedropark99.github.io/zig-book/Chapters/01-base64.html",
};
const project_2 = Exercise{
    .name = "project-2",
    .file_name = "src/project-2/main.zig",
    .run = "project-2",
    .description = "Executa project 2",
};
const project_3 = Exercise{
    .name = "project-3",
    .file_name = "src/project-3.zig",
    .run = "project-3",
    .description = "Executa projeto 3",
};
const project_4 = Exercise{
    .name = "project-4",
    .file_name = "src/project-4.zig",
    .run = "project-4",
    .description = "Executa projeto 4",
};
const exercises = [_]Exercise{ project_1, project_2, project_3, project_4 };

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
