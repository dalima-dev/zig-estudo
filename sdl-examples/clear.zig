const std = @import("std");

const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

pub fn sinf32(value: f64) f32 {
    const result: f32 = @floatCast(c.SDL_sin(value));
    return result;
}

pub fn main() !void {
    c.SDL_SetMainReady();

    _ = c.SDL_SetAppMetadata("Clear", "0.0.0", "sdl-examples.clear");

    _ = c.SDL_Init(c.SDL_INIT_VIDEO);
    defer c.SDL_Quit();

    const window_w = 640;
    const window_h = 480;

    const window: *c.SDL_Window, const renderer: *c.SDL_Renderer = create_window_and_renderer: {
        var window: ?*c.SDL_Window = null;
        var renderer: ?*c.SDL_Renderer = null;
        _ = c.SDL_CreateWindowAndRenderer("Window", window_w, window_h, 0, &window, &renderer);
        errdefer comptime unreachable;

        break :create_window_and_renderer .{ window.?, renderer.? };
    };
    defer c.SDL_DestroyRenderer(renderer);
    defer c.SDL_DestroyWindow(window);

    main_loop: while (true) {
        var event: c.SDL_Event = undefined;

        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) break :main_loop;
        }

        const ticks: f64 = @floatFromInt(c.SDL_GetTicks());
        const now: f64 = ticks / 1000.0;

        const red: f32 = sinf32(0.5 + 0.5 * c.SDL_sin(now));
        const green: f32 = sinf32(0.5 + 0.5 * c.SDL_sin(now + c.SDL_PI_D * 2 / 3));
        const blue: f32 = sinf32(0.5 + 0.5 * c.SDL_sin(now + c.SDL_PI_D * 4 / 3));

        _ = c.SDL_SetRenderDrawColorFloat(renderer, red, green, blue, c.SDL_ALPHA_OPAQUE_FLOAT);
        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderPresent(renderer);
    }
}
