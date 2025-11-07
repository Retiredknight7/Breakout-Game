`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 03:44:26 PM
// Design Name: 
// Module Name: breakout_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module breakout_top(
    input clk,
    input reset,
    input move_left,
    input move_right,
    output [9:0] ball_x,
    output [9:0] ball_y,
    output [9:0] paddle_x
);
    // --- Internal wires ---
    wire collision_left, collision_right, collision_top;
    wire collision_paddle, collision_brick;

    // --- Paddle Y fixed position ---
    wire [9:0] paddle_y = 460;  // near bottom of the screen

    // --- Instantiate Paddle Module ---
    paddle_control paddle_inst (
        .clk(clk),
        .reset(reset),
        .move_left(move_left),
        .move_right(move_right),
        .paddle_x(paddle_x)
    );

    // --- Instantiate Collision Detection ---
    collision_detection coll_inst (
        .ball_x(ball_x),
        .ball_y(ball_y),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .collision_left(collision_left),
        .collision_right(collision_right),
        .collision_top(collision_top),
        .collision_paddle(collision_paddle),
        .collision_brick(collision_brick)
    );

    // --- Instantiate Ball Motion ---
    ball_motion ball_inst (
        .clk(clk),
        .reset(reset),
        .collision_left(collision_left),
        .collision_right(collision_right),
        .collision_top(collision_top),
        .collision_paddle(collision_paddle),
        .collision_brick(collision_brick),
        .ball_x(ball_x),
        .ball_y(ball_y)
    );

endmodule
