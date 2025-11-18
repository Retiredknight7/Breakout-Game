`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Paris Talebi
// Module Name: collision_detection
// Description: Detects collisions between the ball, paddle, and bricks,
//              and signals when the ball is missed (goes beyond paddle)
//////////////////////////////////////////////////////////////////////////////////
module collision_detection #(
    parameter integer H_VISIBLE = 640,
    parameter integer V_VISIBLE = 480,
    parameter integer BALL_R    = 8,    // ball radius (pixels)
    parameter integer PADDLE_W  = 80,   // matches paddle_control
    parameter integer BRICK_W   = 64,
    parameter integer BRICK_H   = 16
)(
    input  wire [9:0] ball_x,
    input  wire [9:0] ball_y,
    input  wire [9:0] paddle_x,
    input  wire [9:0] paddle_y,

    // Optional single-brick probe (tie off if unused)
    input  wire [9:0] brick_x,
    input  wire [9:0] brick_y,
    input  wire       brick_active,

    // Collisions
    output wire collision_left,
    output wire collision_right,
    output wire collision_top,
    output wire collision_paddle,
    output wire collision_brick
);
    // Screen edges
    localparam integer X_MIN = 0;
    localparam integer X_MAX = H_VISIBLE - 1;
    localparam integer Y_MIN = 0;
    localparam integer Y_MAX = V_VISIBLE - 1;

    // --- Wall collisions (treat ball as a disk with radius BALL_R) ---
    assign collision_left  = (ball_x <= (X_MIN + BALL_R));
    assign collision_right = (ball_x >= (X_MAX - BALL_R));
    assign collision_top   = (ball_y <= (Y_MIN + BALL_R));
    // (bottom/miss is handled by game over logic, not bounced)

    // --- Paddle collision (top of paddle) ---
    // Ball intersects paddle band just above paddle_y and horizontally within paddle width
    wire paddle_x0_hit = (ball_x + BALL_R >= paddle_x) &&
                         (ball_x - BALL_R <= paddle_x + PADDLE_W);
    wire paddle_y_hit  = (ball_y + BALL_R >= paddle_y - 1) && // grazing from above
                         (ball_y <  paddle_y + 2);
    assign collision_paddle = paddle_x0_hit && paddle_y_hit;

    // --- Brick AABB hit (simple axis-aligned overlap) ---
    wire brick_on = brick_active;
    wire hit_x = (ball_x + BALL_R >= brick_x) &&
                 (ball_x - BALL_R <= brick_x + BRICK_W);
    wire hit_y = (ball_y + BALL_R >= brick_y) &&
                 (ball_y - BALL_R <= brick_y + BRICK_H);
    assign collision_brick = brick_on && hit_x && hit_y;

endmodule
