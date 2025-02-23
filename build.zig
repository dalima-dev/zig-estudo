const std = @import("std");
const ExecutableOptions = std.Build.ExecutableOptions;

pub const Exercise = struct {
    name: []const u8,
    file_name: []const u8,
    run: []const u8,
    description: []const u8,
};

pub const exercises = [_]Exercise{ .{ .name = "prova-a", .file_name = "src/prova-a.zig", .run = "prova-a", .description = "Executa prova A" }, .{ .name = "prova-b", .file_name = "src/prova-b.zig", .run = "prova-b", .description = "Executa prova B" }, .{ .name = "project-1", .file_name = "src/project-1.zig", .run = "project-1", .description = "https://pedropark99.github.io/zig-book/Chapters/01-base64.html" }, .{ .name = "project-2", .file_name = "src/project-2/main.zig", .run = "project-2", .description = "Executa project 2" } };

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
