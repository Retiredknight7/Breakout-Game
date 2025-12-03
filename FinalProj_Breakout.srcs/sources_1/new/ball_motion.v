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
    reg  signed [1:0] dx, dy;
    reg  signed [1:0] next_dx, next_dy;

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

    // Determine next velocity
    always @* begin
        next_dx = dx;
        next_dy = dy;
        
        // Horizontal bounce
        if ((c_left_z  && dx < 0) ||
            (c_right_z && dx > 0) ||
             c_br_lr_z)
            next_dx = -dx;
        
        // Vertical bounce
        if ((c_top_z    && dy < 0) ||
            (c_paddle_z && dy > 0) ||
             c_br_tb_z)
            next_dy = -dy;
    end

    wire signed [10:0] bx_s = {1'b0, ball_x};
    wire signed [10:0] by_s = {1'b0, ball_y};
    wire signed [10:0] dx_s = {{9{next_dx[1]}}, next_dx};
    wire signed [10:0] dy_s = {{9{next_dy[1]}}, next_dy};
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
            dx     <= 2'sd1;
            dy     <= -2'sd1;
        end else if (frame_tick) begin
            dx     <= next_dx;
            dy     <= next_dy;
            ball_x <= next_ball_x;
            ball_y <= next_ball_y;
        end
    end
endmodule


/*module ball_motion(
    input  wire       clk,        // clk_pix (~25 MHz)
    input  wire       reset,      // rst_pix
    input  wire       frame_tick, // 1 pulse per frame (from vsync edge)

    input  wire       collision_paddle,
    input  wire       collision_left,
    input  wire       collision_right,
    input  wire       collision_top,
    input  wire       collision_brick_leftright,
    input  wire       collision_brick_topbottom,
    input  wire       miss_ball,   // currently ignored

    output reg  [9:0] ball_x,
    output reg  [9:0] ball_y
);
    // velocity: -1, 0, or +1
    reg  signed [1:0] dx, dy;
    reg  signed [1:0] next_dx, next_dy;

    // ---- next-state for velocity (decided once per frame) ----
    always @* begin
        next_dx = dx;
        next_dy = dy;

        // Horizontal flips: only if moving into the wall, or brick LR collision
        if ((collision_left  && dx < 0) ||
            (collision_right && dx > 0) ||
             collision_brick_leftright)
            next_dx = -dx;

        // Vertical flips: top if moving up, paddle if moving down, or brick TB
        if ((collision_top    && dy < 0) ||
            (collision_paddle && dy > 0) ||
             collision_brick_topbottom)
            next_dy = -dy;
    end

    // ---- properly signed position update ----
    // Sign-extend 2-bit velocity to 11 bits, treat position as signed 11 bits,
    // add in 11-bit domain, then truncate back to 10 bits.
    wire signed [10:0] dx_ext  = {{9{next_dx[1]}}, next_dx};
    wire signed [10:0] dy_ext  = {{9{next_dy[1]}}, next_dy};
    wire signed [10:0] bx_s    = {1'b0, ball_x};
    wire signed [10:0] by_s    = {1'b0, ball_y};
    wire signed [10:0] sum_x_s = bx_s + dx_ext;
    wire signed [10:0] sum_y_s = by_s + dy_ext;
    wire        [9:0]  next_ball_x = sum_x_s[9:0];
    wire        [9:0]  next_ball_y = sum_y_s[9:0];

    // ---- sequential state ----
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ball_x <= 10'd320;   // middle-ish
            ball_y <= 10'd100;   // above paddle
            dx     <= 2'sd1;     // start moving down-right for visibility
            dy     <= 2'sd1;
        end else if (frame_tick) begin
            // commit vel first, then move using the new velocity
            dx     <= next_dx;
            dy     <= next_dy;
            ball_x <= next_ball_x;
            ball_y <= next_ball_y;
        end
        
    end
endmodule
*/










/*
module ball_motion(
    input  wire       clk,
    input  wire       reset,
    input  wire       frame_tick,
    input  wire       collision_paddle,
    input  wire       collision_left,           // unused for now
    input  wire       collision_right,          // unused for now
    input  wire       collision_top,            // unused for now
    input  wire       collision_brick_leftright,// unused for now
    input  wire       collision_brick_topbottom,// unused for now
    input  wire       miss_ball,                // unused for now
    output reg  [9:0] ball_x,
    output reg  [9:0] ball_y
);
    // vertical-only motion for debug: dy = +1 or -1
    reg signed [1:0] dy;

    // Power-on / reset position: directly above paddle, falling straight down
    initial begin
        ball_x = 10'd320;   // center over paddle (paddle_x ? 288, width 64)
        ball_y = 10'd100;   // above everything
        dy     = 2'sd1;     // moving down
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ball_x <= 10'd320;
            ball_y <= 10'd100;
            dy     <= 2'sd1;
        end else if (frame_tick) begin
            // *** THIS IS THE ONLY BOUNCE LOGIC ***
            if (collision_paddle)
                dy <= -dy;

            // Move the ball
            ball_y <= ball_y + dy;
            // (ball_x stays constant for now)
        end
    end
endmodule
*/







/*
module ball_motion(
    input clk,
    input reset,
    input frame_tick,
    input collision_paddle,
    //input collision_brick,
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
    
    // Power-on defaults (helps even if reset is never pressed)
    initial begin
        ball_x = 10'd320;   // we'll fix x next
        ball_y = 10'd100;   // clearly above the paddle
        dx     = 2'sd0;     // go straight down
        dy     = 2'sd1;
    end
    
    //initial begin
    //    ball_x = 10'd320;
    //    ball_y = 10'd240;
    //    dx     = 2'sd1;
    //    dy     = -2'sd1;  // up
    //end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Center ball and send it upward-right
            ball_x <= 10'd320;
            ball_y <= 10'd100; //240
            dx     <= 2'sd0; //2'sd0;
            dy     <= 2'sd1; //-2'sd1
        end else if (frame_tick) begin
            // Bounce logic
            
            // Left/right walls OR brick left/right
            if (collision_left || collision_right || collision_brick_leftright)
                dx <= -dx;
            
            // Top wall, paddle, or brick top/bottom
            
            // Top wall: bounce only when going up
            if (collision_top && dy < 0)
                dy <= -dy;
            
            // Paddle: bounce only when going down
            if (collision_paddle && dy > 0)
                dy <= -dy;
            
            // Brick top/bottom: invert always
            if (collision_brick_topbottom)
                dy <= -dy;
            
            
            
            
            //if (collision_top || collision_paddle || collision_brick_topbottom)
            //    dy <= -dy;
            
            // Move ball as long as it didn't miss the paddle
            //if (!miss_ball) begin
                ball_x <= ball_x + dx;
                ball_y <= ball_y + dy;
            //end
        end
    end
endmodule
*/