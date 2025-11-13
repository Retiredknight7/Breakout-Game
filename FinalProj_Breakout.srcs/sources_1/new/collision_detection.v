`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Paris Talebi
// Module Name: collision_detection
// Description: Detects collisions between the ball, paddle, and bricks,
//              and signals when the ball is missed (goes beyond paddle)
//////////////////////////////////////////////////////////////////////////////////

module collision_detection(
    input [9:0] ball_x,
    input [9:0] ball_y,
    input [9:0] paddle_x,
    input [9:0] paddle_y,
    input [9:0] brick_x,
    input [9:0] brick_y,
    input brick_active,        // 1 if brick still on screen
    input [9:0] screen_bottom, // e.g., 480 for 640x480 VGA
    output collision_paddle,
    output collision_brick,
    output miss_ball
);

    // --- Paddle collision detection ---
    // Ball hits paddle if it's just above paddle_y and within paddle width
    assign collision_paddle = (ball_y >= paddle_y - 8) &&
                              (ball_x >= paddle_x) &&
                              (ball_x <= paddle_x + 64);

    // --- Brick collision detection ---
    // Example: brick is 64x16 pixels
    assign collision_brick = brick_active &&
                             (ball_x >= brick_x) && 
                             (ball_x <= brick_x + 64) &&
                             (ball_y >= brick_y) && 
                             (ball_y <= brick_y + 16);

    // --- Miss ball detection ---
    // If ball goes below the paddle (off-screen)
    assign miss_ball = (ball_y > screen_bottom);

endmodule
