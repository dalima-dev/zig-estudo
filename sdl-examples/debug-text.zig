const std = @import("std");

const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

const WINDOW_WIDTH = 640;
const WINDOW_HEIGHT = 480;

pub fn createWindownAndRenderer() struct { *c.SDL_Window, *c.SDL_Renderer } {
    c.SDL_SetMainReady();

    _ = c.SDL_SetAppMetadata("Debug Text", "0.0.0", "sdl-examples.debug-text");
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
    const charsize = c.SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE;

    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderClear(renderer);

    _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderDebugText(renderer, 272, 100, "Hello world!");
    _ = c.SDL_RenderDebugText(renderer, 224, 150, "This is some debug text.");

    _ = c.SDL_SetRenderDrawColor(renderer, 51, 102, 255, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderDebugText(renderer, 184, 200, "You can do it in different colors.");
    _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, c.SDL_ALPHA_OPAQUE);

    _ = c.SDL_SetRenderScale(renderer, 4, 4);
    _ = c.SDL_RenderDebugText(renderer, 14, 65, "It can be scaled.");
    _ = c.SDL_SetRenderScale(renderer, 1, 1);
    _ = c.SDL_RenderDebugText(renderer, 64, 350, "This only does ASCII chars. So this laughing emoji won't draw: 🤣");

    _ = c.SDL_RenderDebugTextFormat(renderer, ((WINDOW_WIDTH - (charsize * 46)) / 2), 400, "(This program has been running for 'unkown' seconds.)", c.SDL_GetTicks() / 1000);

    _ = c.SDL_RenderPresent(renderer);
}

pub fn main() !void {
    const window: *c.SDL_Window, const renderer: *c.SDL_Renderer = createWindownAndRenderer();
    defer c.SDL_Quit();
    defer c.SDL_DestroyRenderer(renderer);
    defer c.SDL_DestroyWindow(window);

    main_loop: while (true) {
        var event: c.SDL_Event = undefined;

        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) break :main_loop;
        }

        render(renderer);
    }
}
