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
    input wire collision_paddle,      // NEW for debuging collison_paddle
    output wire hsync, vsync,
    output wire [11:0] rgb
    );
    
    wire video_on;
    wire [9:0] pixel_x, pixel_y;
    vga_sync sync(.clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y));

    // .collision_paddle(collision_paddle),  // NEW
    pixel_gen generator(.video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y),
                        .paddle_x(paddle_x), .paddle_y(paddle_y), .ball_x(ball_x), .ball_y(ball_y),
                        .bricks(bricks), .collision_paddle(collision_paddle), .rgb(rgb));

endmodule
