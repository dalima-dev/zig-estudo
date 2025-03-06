const std = @import("std");

const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

const WINDOW_WIDTH = 640;
const WINDOW_HEIGHT = 480;

const NUM_POINTS = 500;
const MIN_PIXELS_PER_SECOND = 30;
const MAX_PIXELS_PER_SECOND = 60;

var last_time: u64 = 0;
var current_time: u64 = 0;
var elapsed_time: f32 = 0;

const Velocity = struct {
    x: f32,
    y: f32,
};

const Point = struct {
    position: c.SDL_FPoint,
    velocity: Velocity,
};

var points: [NUM_POINTS]Point = undefined;

pub fn setRandomSpeedToPoint(point: *Point) void {
    const velocity = MIN_PIXELS_PER_SECOND + (c.SDL_randf() * (MAX_PIXELS_PER_SECOND - MIN_PIXELS_PER_SECOND));
    point.velocity.x = velocity;
    point.velocity.y = velocity;
}

pub fn initializePoints() void {
    for (&points) |*point| {
        point.position.x = c.SDL_randf() * WINDOW_WIDTH;
        point.position.y = c.SDL_randf() * WINDOW_HEIGHT;

        setRandomSpeedToPoint(point);
    }
}

pub fn mapPointsToSDLPoints() [NUM_POINTS]c.SDL_FPoint {
    var sdl_points: [NUM_POINTS]c.SDL_FPoint = undefined;

    for (points, 0..) |point, i| {
        sdl_points[i].x = point.position.x;
        sdl_points[i].y = point.position.y;
    }

    return sdl_points;
}

pub fn updatePointsPosition() void {
    for (&points) |*point| {
        const delta_x = elapsed_time * point.velocity.x;
        const delta_y = elapsed_time * point.velocity.y;

        point.position.x += delta_x;
        point.position.y += delta_y;

        if ((point.position.x > WINDOW_WIDTH) or (point.position.y > WINDOW_HEIGHT)) {
            if (c.SDL_rand(2) == 0) {
                point.position.x = 0;
                point.position.y = c.SDL_randf() * WINDOW_HEIGHT;
            } else {
                point.position.x = c.SDL_randf() * WINDOW_WIDTH;
                point.position.y = 0;
            }
            setRandomSpeedToPoint(point);
        }
    }
}

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

pub fn updateFrame() void {
    current_time = c.SDL_GetTicks();
    elapsed_time = @as(f32, @floatFromInt(current_time - last_time)) / 1000;

    updatePointsPosition();

    last_time = c.SDL_GetTicks();
}

pub fn render(renderer: ?*c.SDL_Renderer) void {
    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderClear(renderer);
    _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, c.SDL_ALPHA_OPAQUE);

    const sdl_points = mapPointsToSDLPoints();
    _ = c.SDL_RenderPoints(renderer, &sdl_points[0], @intCast(points.len));

    _ = c.SDL_RenderPresent(renderer);
}

pub fn main() !void {
    const window: *c.SDL_Window, const renderer: *c.SDL_Renderer = createWindownAndRenderer();
    defer c.SDL_Quit();
    defer c.SDL_DestroyRenderer(renderer);
    defer c.SDL_DestroyWindow(window);

    initializePoints();

    last_time = c.SDL_GetTicks();

    main_loop: while (true) {
        var event: c.SDL_Event = undefined;

        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) break :main_loop;
        }

        updateFrame();
        render(renderer);
    }
}
