`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 03:42:43 PM
// Design Name: 
// Module Name: paddel_control
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

module paddle_control(
    input clk,
    input reset,
    input move_left,
    input move_right,
    output reg [9:0] paddle_x
);

    parameter PADDLE_SPEED = 3;
    parameter PADDLE_MIN = 0;
    parameter PADDLE_MAX = 600;

    always @(posedge clk or posedge reset) begin
        if (reset)
            paddle_x <= 300; // start in the middle
        else begin
            if (move_left && paddle_x > PADDLE_MIN)
                paddle_x <= paddle_x - PADDLE_SPEED;
            else if (move_right && paddle_x < PADDLE_MAX)
                paddle_x <= paddle_x + PADDLE_SPEED;
        end
    end

endmodule
