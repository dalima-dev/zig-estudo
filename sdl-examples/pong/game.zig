const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

const objects = @import("objects.zig");
const Ball = objects.Ball;
const Player = objects.Player;

pub const WINDOW_WIDTH = 640;
pub const WINDOW_HEIGHT = 480;

pub var last_time: u64 = 0;
pub var current_time: u64 = 0;
pub var elapsed_time: f32 = 0;

const BALL_SIZE = objects.BALL_SIZE;
const BALL_SPEED = 300;
pub var ball: Ball = undefined;

const PLAYER_WIDTH = objects.PLAYER_WIDTH;
const PLAYER_HEIGHT = objects.PLAYER_HEIGHT;
pub var player_one: Player = undefined;
pub var player_two: Player = undefined;

pub fn handleBallCollisionWithWall() void {
    const ball_position_x = ball.object.position.x;
    const ball_position_y = ball.object.position.y;

    const left_collision = ball_position_x < 0;
    const right_collision = ball_position_x > WINDOW_WIDTH - BALL_SIZE;
    const top_collision = ball_position_y < 0;
    const bottom_collision = ball_position_y > WINDOW_HEIGHT - BALL_SIZE;

    if (left_collision) {
        ball.setVelocity(-ball.object.velocity.x, ball.object.velocity.y);
        ball.setPosition(0, ball_position_y);
    }

    if (right_collision) {
        ball.setVelocity(-ball.object.velocity.x, ball.object.velocity.y);
        ball.setPosition(WINDOW_WIDTH - BALL_SIZE, ball_position_y);
    }

    if (top_collision) {
        ball.setVelocity(ball.object.velocity.x, -ball.object.velocity.y);
        ball.setPosition(ball_position_x, 0);
    }

    if (bottom_collision) {
        ball.setVelocity(ball.object.velocity.x, -ball.object.velocity.y);
        ball.setPosition(ball_position_x, WINDOW_HEIGHT - BALL_SIZE);
    }
}

pub fn updateBallPositionByElapsedTime() void {
    const ball_position_x = ball.object.position.x + ball.object.velocity.x * elapsed_time;
    const ball_position_y = ball.object.position.y + ball.object.velocity.y * elapsed_time;
    ball.setPosition(ball_position_x, ball_position_y);
}

pub fn updateBallState() void {
    updateBallPositionByElapsedTime();
    handleBallCollisionWithWall();
}

pub fn initialize() void {
    ball = Ball.init((WINDOW_WIDTH - BALL_SIZE) / 2, (WINDOW_HEIGHT - BALL_SIZE) / 2, BALL_SPEED, BALL_SPEED);
    player_one = Player.init(10, (WINDOW_HEIGHT - PLAYER_HEIGHT) / 2, 0, 0);
    player_two = Player.init(WINDOW_WIDTH - PLAYER_WIDTH - 10, (WINDOW_HEIGHT - PLAYER_HEIGHT) / 2, 0, 0);
}

pub fn update() void {
    updateBallState();
}

pub fn draw(renderer: ?*c.SDL_Renderer) void {
    ball.draw(renderer);
    player_one.draw(renderer);
    player_two.draw(renderer);
}

pub fn handleEvent(event: c.SDL_Event) !void {
    if (event.type == c.SDL_EVENT_QUIT) return error.Quit;
}
