const std = @import("std");
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

const PADDLE_WIDTH = 10;
const PADDLE_HEIGHT = 50;

const Ball = Object(BALL_SIZE, BALL_SIZE);
const Paddle = Object(PADDLE_WIDTH, PADDLE_HEIGHT);

var ball: Ball = undefined;
var paddle_one: Paddle = undefined;
var paddle_two: Paddle = undefined;

const controller = @import("controller.zig");
var controller_state: controller.ControllerState = .{};

var score_one: u8 = 0;
var score_two: u8 = 0;

fn handleBallCollisionWithWall() void {
    const left_collision = ball.position.x < 0;
    const right_collision = ball.position.x > WINDOW_WIDTH - ball.shape.w;
    const top_collision = ball.position.y < 0;
    const bottom_collision = ball.position.y > WINDOW_HEIGHT - ball.shape.h;

    if (left_collision) {
        score_two += 1;
        ball.velocity.x *= -1;
        ball.setPosition(0, ball.position.y);
    }

    if (right_collision) {
        score_one += 1;
        ball.velocity.x *= -1;
        ball.setPosition(WINDOW_WIDTH - ball.shape.w, ball.position.y);
    }

    if (top_collision) {
        ball.velocity.y *= -1;
        ball.setPosition(ball.position.x, 0);
    }

    if (bottom_collision) {
        ball.velocity.y *= -1;
        ball.setPosition(ball.position.x, WINDOW_HEIGHT - ball.shape.h);
    }
}

fn handlePaddleCollisionWithWall(paddle: *Paddle) void {
    if (paddle.position.y < 0) {
        paddle.setPosition(paddle.position.x, 0);
    }

    if (paddle.position.y > WINDOW_HEIGHT - paddle.shape.h) {
        paddle.setPosition(paddle.position.x, WINDOW_HEIGHT - paddle.shape.h);
    }
}

fn checkBallCollisionWithPaddle(paddle: *Paddle) bool {
    const min_x = ball.position.x - paddle.shape.w;
    const max_x = ball.position.x + ball.shape.w;

    if (paddle.position.x > min_x and paddle.position.x < max_x) {
        const min_y = ball.position.y - paddle.shape.h;
        const max_y = ball.position.y + ball.shape.h;

        if (paddle.position.y > min_y and paddle.position.y < max_y) {
            return true;
        }
    }

    return false;
}

fn handleBallCollisionWithPaddle(paddle: *Paddle) void {
    if (checkBallCollisionWithPaddle(paddle)) {
        const min_collision_position = paddle_one.position.x + paddle_one.shape.w;
        const max_collision_position = paddle_two.position.x - ball.shape.w;

        if (ball.velocity.x < 0 and ball.position.x <= min_collision_position) {
            ball.position.x = min_collision_position;
        }

        if (ball.velocity.x > 0 and ball.position.x >= max_collision_position) {
            ball.position.x = max_collision_position;
        }

        ball.velocity.x = -ball.velocity.x;
    }
}

fn handleScore() void {
    if (score_one == 10 or score_two == 10) {
        score_one = 0;
        score_two = 0;
    }
}

fn drawScore(renderer: ?*c.SDL_Renderer, score: u8, x: f32, y: f32) !void {
    var buf: [10]u8 = undefined;
    const text = try std.fmt.bufPrintZ(&buf, "SCORE {}", .{score});

    _ = c.SDL_SetRenderScale(renderer, 2, 2);
    _ = c.SDL_SetRenderDrawColor(renderer, 0xff, 0xff, 0xff, 0xff);
    _ = c.SDL_RenderDebugText(renderer, x, y, text.ptr);
    _ = c.SDL_SetRenderScale(renderer, 1, 1);
}

fn controlPaddleState(paddle: *Paddle, up: bool, down: bool) void {
    var paddle_vel_y: f32 = 0;
    if (up) paddle_vel_y -= 400;
    if (down) paddle_vel_y += 400;

    paddle.velocity.y = paddle_vel_y;
}

pub fn initialize() void {
    ball = Ball.init((WINDOW_WIDTH - BALL_SIZE) / 2, (WINDOW_HEIGHT - BALL_SIZE) / 2, BALL_SPEED, BALL_SPEED);
    paddle_one = Paddle.init(10, (WINDOW_HEIGHT - PADDLE_HEIGHT) / 2, 0, 0);
    paddle_two = Paddle.init(WINDOW_WIDTH - PADDLE_WIDTH - 10, (WINDOW_HEIGHT - PADDLE_HEIGHT) / 2, 0, 0);
}

pub fn update() void {
    ball.updatePositionByTime(elapsed_time_ptr.*);
    handleBallCollisionWithWall();

    paddle_one.updatePositionByTime(elapsed_time_ptr.*);
    handlePaddleCollisionWithWall(&paddle_one);

    paddle_two.updatePositionByTime(elapsed_time_ptr.*);
    handlePaddleCollisionWithWall(&paddle_two);

    handleBallCollisionWithPaddle(&paddle_one);
    handleBallCollisionWithPaddle(&paddle_two);

    handleScore();

    controlPaddleState(&paddle_one, controller_state.key_w, controller_state.key_s);
    controlPaddleState(&paddle_two, controller_state.key_o, controller_state.key_k);
}

pub fn draw(renderer: ?*c.SDL_Renderer) !void {
    try drawScore(renderer, score_one, 8, 8);
    try drawScore(renderer, score_two, WINDOW_WIDTH - 383, 8);
    ball.draw(renderer);
    paddle_one.draw(renderer);
    paddle_two.draw(renderer);
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
