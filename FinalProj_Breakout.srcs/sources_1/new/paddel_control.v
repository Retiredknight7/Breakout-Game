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

module paddle_control#(
    parameter integer H_VISIBLE    = 640,
    parameter integer PADDLE_W     = 80,
    parameter integer PADDLE_Y     = 460,
    parameter integer PADDLE_SPEED = 8
    )(
    input clk,
    input reset,
    
    // 1-cycle pulse per frame (from vsync rising edge)
    input  wire        frame_tick,
    
    // Debounced button levels (1 while held)
    input  wire        move_left_hold,
    input  wire        move_right_hold,

    // One-shot pulses on press
    input  wire        move_left_step,
    input  wire        move_right_step,
    
    output reg [9:0] paddle_x,
    output wire [9:0]  paddle_y
);
    localparam integer X_MIN = 0;
    localparam integer X_MAX = H_VISIBLE - PADDLE_W;
    
    assign paddle_y = PADDLE_Y[9:0];
    // Move if either the hold-level or step-pulse is active
    wire move_left  = move_left_hold  | move_left_step;
    wire move_right = move_right_hold | move_right_step;
   
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            paddle_x <= (H_VISIBLE - PADDLE_W)/2;  // center on reset
        end else if (frame_tick) begin
            // One update per frame (smooth & deterministic)
            if (move_left & ~move_right) begin
                if (paddle_x > X_MIN + PADDLE_SPEED)
                    paddle_x <= paddle_x - PADDLE_SPEED;
                else
                    paddle_x <= X_MIN[9:0];
            end else if (move_right & ~move_left) begin
                if (paddle_x + PADDLE_W + PADDLE_SPEED < H_VISIBLE)
                    paddle_x <= paddle_x + PADDLE_SPEED;
                else
                    paddle_x <= X_MAX[9:0];
            end
            // both pressed or none pressed => hold position
        end
    end
endmodule
