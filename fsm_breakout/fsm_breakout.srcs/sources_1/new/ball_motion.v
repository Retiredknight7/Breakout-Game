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
    input collision_left,
    input collision_right,
    input collision_top,
    input collision_paddle,
    input collision_brick,
    output reg [9:0] ball_x,
    output reg [9:0] ball_y
);

    reg signed [1:0] dx, dy; // direction: -1 or +1

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ball_x <= 320; // start at middle
            ball_y <= 240;
            dx <= 1;
            dy <= -1;
        end else begin
            // Bounce logic
            if (collision_left || collision_right)
                dx <= -dx;
            if (collision_top || collision_paddle || collision_brick)
                dy <= -dy;

            // Move ball
            ball_x <= ball_x + dx;
            ball_y <= ball_y + dy;
        end
    end

endmodule
