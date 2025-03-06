const std = @import("std");

const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

const WINDOW_WIDTH = 640;
const WINDOW_HEIGHT = 480;

var line_points: [9]c.SDL_FPoint = undefined;

pub fn initializeLinePoints() void {
    line_points[0] = c.SDL_FPoint{ .x = 100, .y = 354 };
    line_points[1] = c.SDL_FPoint{ .x = 220, .y = 230 };
    line_points[2] = c.SDL_FPoint{ .x = 140, .y = 230 };
    line_points[3] = c.SDL_FPoint{ .x = 320, .y = 100 };
    line_points[4] = c.SDL_FPoint{ .x = 500, .y = 230 };
    line_points[5] = c.SDL_FPoint{ .x = 420, .y = 230 };
    line_points[6] = c.SDL_FPoint{ .x = 540, .y = 354 };
    line_points[7] = c.SDL_FPoint{ .x = 400, .y = 354 };
    line_points[8] = c.SDL_FPoint{ .x = 100, .y = 354 };
}

pub fn createWindownAndRenderer() struct { *c.SDL_Window, *c.SDL_Renderer } {
    c.SDL_SetMainReady();

    _ = c.SDL_SetAppMetadata("Lines", "0.0.0", "sdl-examples.lines");
    _ = c.SDL_Init(c.SDL_INIT_VIDEO);

    const window: *c.SDL_Window, const renderer: *c.SDL_Renderer = create_window_and_renderer: {
        var window: ?*c.SDL_Window = null;
        var renderer: ?*c.SDL_Renderer = null;
        _ = c.SDL_CreateWindowAndRenderer("Window", WINDOW_WIDTH, WINDOW_HEIGHT, 0, &window, &renderer);
        errdefer comptime unreachable;

        break :create_window_and_renderer .{ window.?, renderer.? };
    };

    return .{ window, renderer };
}

pub fn render(renderer: ?*c.SDL_Renderer) void {
    _ = c.SDL_SetRenderDrawColor(renderer, 100, 100, 100, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderClear(renderer);

    _ = c.SDL_SetRenderDrawColor(renderer, 127, 49, 32, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderLine(renderer, 240, 450, 400, 450);
    _ = c.SDL_RenderLine(renderer, 240, 356, 400, 356);
    _ = c.SDL_RenderLine(renderer, 240, 356, 240, 450);
    _ = c.SDL_RenderLine(renderer, 400, 356, 400, 450);

    _ = c.SDL_SetRenderDrawColor(renderer, 0, 255, 0, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderLines(renderer, &line_points[0], @intCast(line_points.len));

    for (0..360) |i| {
        const size: f32 = 30;
        const x: f32 = 320;
        const y: f32 = 95 - (size / 2);

        _ = c.SDL_SetRenderDrawColor(renderer, @intCast(c.SDL_rand(256)), @intCast(c.SDL_rand(256)), @intCast(c.SDL_rand(256)), c.SDL_ALPHA_OPAQUE);
        _ = c.SDL_RenderLine(renderer, x, y, x + c.SDL_sinf(@floatFromInt(i)) * size, y + c.SDL_cosf(@floatFromInt(i)) * size);
    }

    _ = c.SDL_RenderPresent(renderer);
}

pub fn main() !void {
    const window: *c.SDL_Window, const renderer: *c.SDL_Renderer = createWindownAndRenderer();
    defer c.SDL_Quit();
    defer c.SDL_DestroyRenderer(renderer);
    defer c.SDL_DestroyWindow(window);

    initializeLinePoints();

    main_loop: while (true) {
        var event: c.SDL_Event = undefined;

        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) break :main_loop;
        }

        render(renderer);
    }
}
