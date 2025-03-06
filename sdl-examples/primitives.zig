const std = @import("std");

const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

const WINDOW_WIDTH = 640;
const WINDOW_HEIGHT = 480;

var points: [500]c.SDL_FPoint = undefined;

pub fn createWindownAndRenderer() struct { *c.SDL_Window, *c.SDL_Renderer } {
    c.SDL_SetMainReady();

    _ = c.SDL_SetAppMetadata("Clear", "0.0.0", "sdl-examples.clear");
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

fn generateSeed() !u64 {
    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));

    return seed;
}

pub fn initializePoints() !void {
    const seed = try generateSeed();
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();

    for (&points) |*point| {
        point.x = rand.float(f32) * 440 + 100;
        point.y = rand.float(f32) * 280 + 100;
    }
}

pub fn render(renderer: ?*c.SDL_Renderer) void {
    var rect: c.SDL_FRect = undefined;

    _ = c.SDL_SetRenderDrawColor(renderer, 33, 33, 33, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderClear(renderer);

    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 255, c.SDL_ALPHA_OPAQUE);
    rect.x = 100;
    rect.y = 100;
    rect.w = 440;
    rect.h = 280;
    _ = c.SDL_RenderFillRect(renderer, &rect);

    _ = c.SDL_SetRenderDrawColor(renderer, 255, 0, 0, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderPoints(renderer, &points[0], @intCast(points.len));

    _ = c.SDL_SetRenderDrawColor(renderer, 0, 255, 0, c.SDL_ALPHA_OPAQUE);
    rect.x += 30;
    rect.y += 30;
    rect.w -= 60;
    rect.h -= 60;
    _ = c.SDL_RenderRect(renderer, &rect);

    _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 0, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderLine(renderer, 0, 0, 640, 480);
    _ = c.SDL_RenderLine(renderer, 0, 480, 640, 0);

    _ = c.SDL_RenderPresent(renderer);
}

pub fn main() !void {
    const window: *c.SDL_Window, const renderer: *c.SDL_Renderer = createWindownAndRenderer();
    defer c.SDL_Quit();
    defer c.SDL_DestroyRenderer(renderer);
    defer c.SDL_DestroyWindow(window);

    try initializePoints();

    main_loop: while (true) {
        var event: c.SDL_Event = undefined;

        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) break :main_loop;
        }

        render(renderer);
    }
}
