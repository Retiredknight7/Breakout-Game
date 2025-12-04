`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CSULB
// Engineer: Yshi Blanco
// Create Date: 12/02/2025 02:38:12 PM
// Module Name: collision_detection_tb
// Project Name: Breakout
// Description: Directed test bench for collision detection
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module collision_detection_tb(

    );
    
    reg [9:0] ball_x, ball_y, paddle_x, paddle_y;
    reg [76:0] active_bricks;
    
    wire collision_left, collision_right, collision_top, collision_paddle,
        collision_brick_leftright, collision_brick_topbottom;
    wire [6:0] hit_idx;
    wire miss_ball;
    
    // Instantiate UUT
    collision_detection uut(
        .ball_x(ball_x),
        .ball_y(ball_y),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .active_bricks(active_bricks),
        .collision_left(collision_left),
        .collision_right(collision_right),
        .collision_top(collision_top),
        .collision_paddle(collision_paddle),
        .collision_brick_leftright(collision_brick_leftright),
        .collision_brick_topbottom(collision_brick_topbottom),
        .hit_idx(hit_idx),
        .miss_ball(miss_ball)
    );
    
    initial begin
        // Initially, no collisions
        ball_x = 320;
        ball_y = 360;
        paddle_x = 288;
        paddle_y = 432;
        active_bricks = {77{1'b1}};        
        #10;
        
        // Collision with left border
        ball_x = 0;         // leftmost of screen
        ball_y = 360;       // near bottom of screen
        #10;
        $display("Left Border Collision: %s", (collision_left) ? "Passed" : "Failed");
        #10;
        
        // Collision with right border
        ball_x = 640;       // rightmost of screen
        ball_y = 360;       // near bottom of screen
        #10;
        $display("Right Border Collision: %s", (collision_right) ? "Passed" : "Failed");
        #10;
        
        // Collision with top border
        ball_x = 320;       // middle-ish of screen
        ball_y = 0;         // topmost edge of screen
        #10;
        $display("Top Border Collision: %s", (collision_top) ? "Passed" : "Failed");
        #10;
        
        // Collision with bottom border
        ball_x = 320;       // middle-ish of screen
        ball_y = 480;       // bottom of the screen
        #10;
        $display("Bottom Border Collision: %s", (miss_ball) ? "Passed" : "Failed");
        #10;
        
        // Collision with paddle
        ball_x = 288;       // paddle position
        ball_y = 432;       // paddle position
        #10;
        $display("Paddle Collision: %s", (collision_paddle) ? "Passed" : "Failed");
        #10;                 // need to read brick collisions after rising edge
        
        // Collision with left/right sides of brick
        ball_x = 9;         // Left of top left brick
        ball_y = 50;
        #10;
        $display("Left/Right Brick Collision: %s", (collision_brick_leftright) ? "Passed" : "Failed");
        #10;
        
        // Collision with top/bottom sides of brick
        ball_x = 16;        // Top of top left brick
        ball_y = 41;
        #10;
        $display("Top/Bottom Brick Collision: %s", (collision_brick_topbottom) ? "Passed" : "Failed");
        #10;
    end
endmodule
