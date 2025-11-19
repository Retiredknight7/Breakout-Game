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
<<<<<<< HEAD
    input  wire        clk,        // <- this IS the pixel clock (clk_pix)
    input  wire        reset,

    // live positions
    input  wire [9:0]  paddle_x,
    input  wire [9:0]  paddle_y,
    input  wire [9:0]  ball_x,
    input  wire [9:0]  ball_y,

    // VGA out
    output wire        hsync,
    output wire        vsync,
    output wire        video_on,
=======
    input clk, reset,
    input wire [9:0] paddle_x, paddle_y, ball_x, ball_y,
    input wire [76:0] bricks,            // map of 77 bricks
    output wire hsync, vsync,
>>>>>>> 03d97bf (modified ball_motion and collision_detection to integrate with vga_controller; needs to be tested)
    output wire [11:0] rgb
);
    // NO local clocking here. Use the provided pixel clock `clk`.

    // VGA timing on pixel clock
    wire [9:0] pixel_x, pixel_y;
<<<<<<< HEAD
    vga_sync sync (
        .clk     (clk),     // pixel clock from top
        .reset   (reset),
        .hsync   (hsync),
        .vsync   (vsync),
        .video_on(video_on),
        .pixel_x (pixel_x),
        .pixel_y (pixel_y)
    );

    // Static full brick wall (ok to keep as-is)
    wire [76:0] bricks = {77{1'b1}};
=======
    vga_sync sync(.clk(clk_divided), .reset(reset), .hsync(hsync), .vsync(vsync), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y));
    
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

    // Full wall of 11x7 bricks
    wire [76:0] bricks = {77{1'b1}};
    */
    
    pixel_gen generator(.video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y),
                        .paddle_x(paddle_x), .paddle_y(paddle_y), .ball_x(ball_x), .ball_y(ball_y),
                        .bricks(bricks), .rgb(rgb));
>>>>>>> 03d97bf (modified ball_motion and collision_detection to integrate with vga_controller; needs to be tested)

    // Pixel generator uses live game positions
    pixel_gen generator(
        .video_on(video_on),
        .pixel_x (pixel_x),
        .pixel_y (pixel_y),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .ball_x  (ball_x),
        .ball_y  (ball_y),
        .bricks  (bricks),
        .rgb     (rgb)
    );
endmodule