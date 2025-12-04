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

module ball_motion #(
    parameter integer BALL_SIZE = 8
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       frame_tick,
    input  wire       game_enable,

    input  wire       collision_paddle,
    input  wire       collision_left,
    input  wire       collision_right,
    input  wire       collision_top,
    input  wire       collision_brick_leftright,
    input  wire       collision_brick_topbottom,
    input  wire       miss_ball,
    input  wire [9:0] paddle_y,

    output reg  [9:0] ball_x,
    output reg  [9:0] ball_y
);
    reg  signed [2:0] dx, dy;
    reg  signed [2:0] next_dx, next_dy;

    reg c_paddle_z, c_left_z, c_right_z, c_top_z, c_br_lr_z, c_br_tb_z;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            {c_paddle_z, c_left_z, c_right_z, c_top_z, c_br_lr_z, c_br_tb_z} <= 6'b0;
        end else if (frame_tick) begin
            c_paddle_z <= collision_paddle;
            c_left_z   <= collision_left;
            c_right_z  <= collision_right;
            c_top_z    <= collision_top;
            c_br_lr_z  <= collision_brick_leftright;
            c_br_tb_z  <= collision_brick_topbottom;
        end
    end
    
    reg brick_bounce_hold;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            brick_bounce_hold <= 1'b0;
        end else if (frame_tick) begin
            if (c_br_lr_z || c_br_tb_z)
                brick_bounce_hold <= 1'b1;   // in a brick contact, already bounced
            else
                brick_bounce_hold <= 1'b0;   // fully out of any brick => can bounce again
        end
    end

    // Determine next velocity
    always @* begin
        next_dx = dx;
        next_dy = dy;
        
        // Wall / paddle bounces (always allowed)
        if ((c_left_z  && dx < 0) ||
            (c_right_z && dx > 0))
            next_dx = -dx;
        
        if ((c_top_z    && dy < 0) ||
            (c_paddle_z && dy > 0))
            next_dy = -dy;

        // Brick bounces: only if we are NOT already in a brick
        if (!brick_bounce_hold) begin
            if (c_br_lr_z)
                next_dx = -next_dx;   // bounce horizontally
            if (c_br_tb_z)
                next_dy = -next_dy;   // bounce vertically
        end
    end

    wire signed [10:0] bx_s = {1'b0, ball_x};
    wire signed [10:0] by_s = {1'b0, ball_y};
    wire signed [10:0] dx_s = {{8{next_dx[2]}}, next_dx};
    wire signed [10:0] dy_s = {{8{next_dy[2]}}, next_dy};
    wire signed [10:0] sum_x_s = bx_s + dx_s;
    wire signed [10:0] sum_y_s = by_s + dy_s;

    reg [9:0] next_ball_x, next_ball_y;
    always @* begin
        next_ball_x = sum_x_s[9:0];
        next_ball_y = sum_y_s[9:0];
        if (c_paddle_z && (dy > 0))
            next_ball_y = paddle_y - BALL_SIZE;
    end
    
    
    // State updates
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ball_x <= 10'd320;
            ball_y <= 10'd360; //paddle_y - BALL_SIZE - 20;//10'd380;
            dx     <= 3'sd2;
            dy     <= 3'sd2;
        end else if (frame_tick && game_enable) begin
        
            // Move ball as long as it didn't hit bottom borer
            if (!miss_ball) begin
                dx     <= next_dx;
                dy     <= next_dy;
                ball_x <= next_ball_x;
                ball_y <= next_ball_y;
            end
        end
    end
endmodule