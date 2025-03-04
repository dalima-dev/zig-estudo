const std = @import("std");

const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

pub fn main() !void {
    c.SDL_SetMainReady();

    _ = c.SDL_SetAppMetadata("Window", "0.0.0", "sdl-examples.window");

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
        var timeoutMS: i32 = -1;

        while (c.SDL_WaitEventTimeout(&event, timeoutMS)) : (timeoutMS = 0) {
            if (event.type == c.SDL_EVENT_QUIT) break :main_loop;
        }
    }
}
