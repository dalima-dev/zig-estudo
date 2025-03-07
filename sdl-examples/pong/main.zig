const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});
const engine = @import("engine.zig");

const WINDOW_WIDTH = engine.WINDOW_WIDTH;
const WINDOW_HEIGHT = engine.WINDOW_HEIGHT;

var last_time_ptr: *u64 = &engine.last_time;
var current_time_ptr: *u64 = &engine.current_time;
var elapsed_time_ptr: *f32 = &engine.elapsed_time;

pub fn createWindownAndRenderer() struct { *c.SDL_Window, *c.SDL_Renderer } {
    c.SDL_SetMainReady();

    _ = c.SDL_SetAppMetadata("Points", "0.0.0", "sdl-examples.points");
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

fn render(renderer: ?*c.SDL_Renderer) void {
    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderClear(renderer);

    engine.draw(renderer);

    _ = c.SDL_RenderPresent(renderer);
}

pub fn main() !void {
    const window: *c.SDL_Window, const renderer: *c.SDL_Renderer = createWindownAndRenderer();
    defer c.SDL_Quit();
    defer c.SDL_DestroyRenderer(renderer);
    defer c.SDL_DestroyWindow(window);

    last_time_ptr.* = c.SDL_GetTicks();
    engine.initialize();

    main_loop: while (true) {
        var event: c.SDL_Event = undefined;

        while (c.SDL_PollEvent(&event)) {
            engine.handleEvent(event) catch |err| {
                if (err == error.Quit) break :main_loop;
            };
        }

        {
            current_time_ptr.* = c.SDL_GetTicks();
            elapsed_time_ptr.* = @as(f32, @floatFromInt(current_time_ptr.* - last_time_ptr.*)) / 1000;
            engine.update();
            last_time_ptr.* = c.SDL_GetTicks();
        }

        render(renderer);
    }
}
