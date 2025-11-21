`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CSULB
// Engineer: Yshi Blanco
// Create Date: 10/22/2025 02:08:44 PM
// Design Name: VGA Controller
// Module Name: vga_controller
// Project Name: Breakout
// Description: Top level module to control display via VGA
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module vga_controller(
    input clk, reset,
    input wire [9:0] paddle_x, paddle_y, ball_x, ball_y,
    input wire [76:0] bricks,
    output wire hsync, vsync,
    output wire [11:0] rgb
    );
    
    /* WITHOUT CLOCK DIVIDER
    // Clock divider to 25MHz
    wire clk_divided;
    vga_clk clk_divider(.clk(clk), .reset(reset), .clk_out(clk_divided));
    
    // VGA synchronization for timing frequency
    wire video_on;
    wire [9:0] pixel_x, pixel_y;
    vga_sync sync(.clk(clk_divided), .reset(reset), .hsync(hsync), .vsync(vsync), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y));
    */
    
    wire video_on;
    wire [9:0] pixel_x, pixel_y;
    vga_sync sync(.clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y));
    
    /* TEST FOR DRAWING A STILL
    // Constants to draw a still image of the game
    // Positions
    localparam PADDLE_X0 = 288;
    localparam PADDLE_Y0 = 432;
    localparam BALL_X0   = 300;
    localparam BALL_Y0   = 332;

    wire [9:0] paddle_x = PADDLE_X0[9:0];
    wire [9:0] paddle_y = PADDLE_Y0[9:0];
    wire [9:0] ball_x   = BALL_X0[9:0];
    wire [9:0] ball_y   = BALL_Y0[9:0];

    // Full wall of 9x7 bricks
    wire [76:0] bricks = {77{1'b1}};
    */
    
    pixel_gen generator(.video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y),
                        .paddle_x(paddle_x), .paddle_y(paddle_y), .ball_x(ball_x), .ball_y(ball_y),
                        .bricks(bricks), .rgb(rgb));

endmodule
