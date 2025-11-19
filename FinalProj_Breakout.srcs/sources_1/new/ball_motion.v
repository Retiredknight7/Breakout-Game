`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 03:42:04 PM
// Design Name: 
// Module Name: ball_motion
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

module ball_motion(
<<<<<<< HEAD
    input  wire        clk,
    input  wire        reset,
    input  wire        frame_tick,       //advance once per frame
    input  wire        collision_left,
    input  wire        collision_right,
    input  wire        collision_top,
    input  wire        collision_paddle,
    input  wire        collision_brick,
    output reg  [9:0]  ball_x,
    output reg  [9:0]  ball_y
=======
    input clk,
    input reset,
    input collision_paddle,
    input collision_brick,
    input collision_left,
    input collision_right,
    input collision_top,
    input collision_brick_leftright,
    input collision_brick_topbottom,
    input miss_ball,
    output reg [9:0] ball_x,
    output reg [9:0] ball_y
>>>>>>> 03d97bf (modified ball_motion and collision_detection to integrate with vga_controller; needs to be tested)
);
    // signed step (+1 / -1). Use 2-bit signed to avoid width warnings
    reg signed [1:0] dx, dy;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
<<<<<<< HEAD
            ball_x <= 10'd320;
            ball_y <= 10'd240;
            dx <= 2'sd1;
            dy <= -2'sd1;
        end else if (frame_tick) begin
            // bounce decisions first
            if (collision_left  || collision_right)  dx <= -dx;
            if (collision_top   || collision_paddle || collision_brick) dy <= -dy;

            // then move
            ball_x <= ball_x + dx;
            ball_y <= ball_y + dy;
=======
            ball_x <= 320; // start at middle
            ball_y <= 240;
            dx <= 1;
            dy <= -1;
        end else begin
            // Bounce logic
            if (collision_left || collision_right || collision_brick_leftright)
                dx <= ~dx;
            if (collision_top || collision_paddle || collision_brick_topbottom)
                dy <= ~dy;

            // Move ball as long as it didn't miss the paddle
            if (!miss_ball) begin
                ball_x <= ball_x + dx;
                ball_y <= ball_y + dy;
            end
>>>>>>> 03d97bf (modified ball_motion and collision_detection to integrate with vga_controller; needs to be tested)
        end
    end
endmodule
