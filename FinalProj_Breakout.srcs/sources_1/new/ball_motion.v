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
    input clk,
    input reset,
    input frame_tick,
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
);
    // signed step (+1 / -1). Use 2-bit signed to avoid width warnings
    reg signed [1:0] dx, dy;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ball_x <= 320; // start at middle
            ball_y <= 240;
            dx <= 1;
            dy <= -1;
        end else if (frame_tick) begin
            // Bounce logic
            if (collision_left || collision_right || collision_brick_leftright)
                dx <= -dx;
            if (collision_top || collision_paddle || collision_brick_topbottom)
                dy <= -dy;

            // Move ball as long as it didn't miss the paddle
            if (!miss_ball) begin
                ball_x <= ball_x + dx;
                ball_y <= ball_y + dy;
            end
        end
    end
endmodule
