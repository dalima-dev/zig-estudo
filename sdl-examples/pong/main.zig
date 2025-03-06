const std = @import("std");

const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

const WINDOW_WIDTH = 640;
const WINDOW_HEIGHT = 480;

var last_time: u64 = 0;
var current_time: u64 = 0;
var elapsed_time: f32 = 0;

const BALL_SIZE = 10;
const ball = Ball.init((WINDOW_WIDTH - BALL_SIZE) / 2, (WINDOW_HEIGHT - BALL_SIZE) / 2, 100, 100);

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

fn initializeAppState() void {
    last_time = c.SDL_GetTicks();

    // initialize objects here...
}

fn updateAppState() void {
    current_time = c.SDL_GetTicks();
    elapsed_time = @as(f32, @floatFromInt(current_time - last_time)) / 1000;

    // update objects here...

    last_time = c.SDL_GetTicks();
}

fn render(renderer: ?*c.SDL_Renderer) void {
    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderClear(renderer);

    // render objects here...
    ball.draw(renderer);

    _ = c.SDL_RenderPresent(renderer);
}

pub fn main() !void {
    const window: *c.SDL_Window, const renderer: *c.SDL_Renderer = createWindownAndRenderer();
    defer c.SDL_Quit();
    defer c.SDL_DestroyRenderer(renderer);
    defer c.SDL_DestroyWindow(window);

    initializeAppState();

    main_loop: while (true) {
        var event: c.SDL_Event = undefined;

        // implement a function to handle events here...
        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) break :main_loop;
        }

        updateAppState();
        render(renderer);
    }
}

const Position = struct {
    x: f32,
    y: f32,
};

const Velocity = struct {
    x: f32,
    y: f32,
};

const Object = struct {
    position: Position,
    velocity: Velocity,
};

const Ball = struct {
    object: Object,
    shape: c.SDL_FRect,

    pub fn init(pos_x: f32, pos_y: f32, vel_x: f32, vel_y: f32) Ball {
        return Ball{
            .object = .{
                .position = .{ .x = pos_x, .y = pos_y },
                .velocity = .{ .x = vel_x, .y = vel_y },
            },
            .shape = c.SDL_FRect{
                .x = pos_x,
                .y = pos_y,
                .w = BALL_SIZE,
                .h = BALL_SIZE,
            },
        };
    }

    pub fn draw(self: Ball, renderer: ?*c.SDL_Renderer) void {
        const rect = self.shape;
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, c.SDL_ALPHA_OPAQUE);
        _ = c.SDL_RenderFillRect(renderer, &rect);
    }
};
