const main = @import("main.zig");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

const object = @import("object.zig");
const Object = object.Object;

pub const WINDOW_WIDTH = 640;
pub const WINDOW_HEIGHT = 480;

var elapsed_time_ptr: *f32 = &main.elapsed_time;

const BALL_SIZE = 10;
const BALL_SPEED = 300;

const PLAYER_WIDTH = 10;
const PLAYER_HEIGHT = 50;

const Ball = Object(BALL_SIZE, BALL_SIZE);
const Player = Object(PLAYER_WIDTH, PLAYER_HEIGHT);

var ball: Ball = undefined;
var player_one: Player = undefined;
var player_two: Player = undefined;

const controller = @import("controller.zig");
var controller_state: controller.ControllerState = .{};

fn handleBallCollisionWithWall() void {
    const ball_position_x = ball.position.x;
    const ball_position_y = ball.position.y;

    const left_collision = ball_position_x < 0;
    const right_collision = ball_position_x > WINDOW_WIDTH - BALL_SIZE;
    const top_collision = ball_position_y < 0;
    const bottom_collision = ball_position_y > WINDOW_HEIGHT - BALL_SIZE;

    if (left_collision) {
        ball.setVelocity(-ball.velocity.x, ball.velocity.y);
        ball.setPosition(0, ball_position_y);
    }

    if (right_collision) {
        ball.setVelocity(-ball.velocity.x, ball.velocity.y);
        ball.setPosition(WINDOW_WIDTH - BALL_SIZE, ball_position_y);
    }

    if (top_collision) {
        ball.setVelocity(ball.velocity.x, -ball.velocity.y);
        ball.setPosition(ball_position_x, 0);
    }

    if (bottom_collision) {
        ball.setVelocity(ball.velocity.x, -ball.velocity.y);
        ball.setPosition(ball_position_x, WINDOW_HEIGHT - BALL_SIZE);
    }
}

fn handlePlayerCollisionWithWall(player: *Player) void {
    if (player.position.y < 0) {
        player.setPosition(player.position.x, 0);
    }

    if (player.position.y > WINDOW_HEIGHT - player.shape.h) {
        player.setPosition(player.position.x, WINDOW_HEIGHT - player.shape.h);
    }
}

fn controlPlayerState(player: *Player, up: bool, down: bool) void {
    var player_vel_y: f32 = 0;
    if (up) player_vel_y -= 400;
    if (down) player_vel_y += 400;

    player.setVelocity(0, player_vel_y);
}

pub fn initialize() void {
    ball = Ball.init((WINDOW_WIDTH - BALL_SIZE) / 2, (WINDOW_HEIGHT - BALL_SIZE) / 2, BALL_SPEED, BALL_SPEED);
    player_one = Player.init(10, (WINDOW_HEIGHT - PLAYER_HEIGHT) / 2, 0, 0);
    player_two = Player.init(WINDOW_WIDTH - PLAYER_WIDTH - 10, (WINDOW_HEIGHT - PLAYER_HEIGHT) / 2, 0, 0);
}

pub fn update() void {
    ball.updatePositionByTime(elapsed_time_ptr.*);
    handleBallCollisionWithWall();

    player_one.updatePositionByTime(elapsed_time_ptr.*);
    handlePlayerCollisionWithWall(&player_one);

    player_two.updatePositionByTime(elapsed_time_ptr.*);
    handlePlayerCollisionWithWall(&player_two);

    controlPlayerState(&player_one, controller_state.key_w, controller_state.key_s);
    controlPlayerState(&player_two, controller_state.key_o, controller_state.key_k);
}

pub fn draw(renderer: ?*c.SDL_Renderer) void {
    ball.draw(renderer);
    player_one.draw(renderer);
    player_two.draw(renderer);
}

pub fn handleEvent(event: c.SDL_Event) !void {
    switch (event.type) {
        c.SDL_EVENT_QUIT => {
            return error.Quit;
        },
        c.SDL_EVENT_KEY_DOWN, c.SDL_EVENT_KEY_UP => {
            const down = event.type == c.SDL_EVENT_KEY_DOWN;
            switch (event.key.scancode) {
                c.SDL_SCANCODE_W => controller_state.key_w = down,
                c.SDL_SCANCODE_S => controller_state.key_s = down,
                c.SDL_SCANCODE_O => controller_state.key_o = down,
                c.SDL_SCANCODE_K => controller_state.key_k = down,
                else => {},
            }
        },
        else => {},
    }
}
