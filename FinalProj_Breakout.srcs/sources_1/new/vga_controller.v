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
    output wire [11:0] rgb
);
    // NO local clocking here. Use the provided pixel clock `clk`.

    // VGA timing on pixel clock
    wire [9:0] pixel_x, pixel_y;
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