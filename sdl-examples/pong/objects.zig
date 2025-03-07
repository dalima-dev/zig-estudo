const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

pub const BALL_SIZE = 10;

const Position = struct {
    x: f32,
    y: f32,
};

const Velocity = struct {
    x: f32,
    y: f32,
};

pub const Object = struct {
    position: Position,
    velocity: Velocity,
};

pub const Ball = struct {
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

    pub fn setPosition(self: *Ball, x: f32, y: f32) void {
        self.object.position.x = x;
        self.object.position.y = y;

        self.shape.x = x;
        self.shape.y = y;
    }

    pub fn setVelocity(self: *Ball, x: f32, y: f32) void {
        self.object.velocity.x = x;
        self.object.velocity.y = y;
    }

    pub fn draw(self: *Ball, renderer: ?*c.SDL_Renderer) void {
        const rect = self.shape;
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, c.SDL_ALPHA_OPAQUE);
        _ = c.SDL_RenderFillRect(renderer, &rect);
    }
};
