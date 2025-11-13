`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 03:43:20 PM
// Design Name: 
// Module Name: collision_detection
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

module collision_detection(
    input [9:0] ball_x,
    input [9:0] ball_y,
    input [9:0] paddle_x,
    input [9:0] paddle_y,
    output collision_left,
    output collision_right,
    output collision_top,
    output collision_paddle,
    output collision_brick
);

    assign collision_left  = (ball_x <= 0);
    assign collision_right = (ball_x >= 639);
    assign collision_top   = (ball_y <= 0);
    assign collision_paddle = (ball_y >= paddle_y - 8) && 
                              (ball_x >= paddle_x) && 
                              (ball_x <= paddle_x + 64);
    assign collision_brick = 1'b0; // placeholder - connect to brick array later

endmodule
