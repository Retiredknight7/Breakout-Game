`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CSULB
// Engineer: Yshi Blanco
// Create Date: 12/02/2025 02:38:12 PM
// Module Name: ball_motion_tb
// Project Name: Breakout
// Description: Directed testbench for ball physics
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module ball_motion_tb(

    );
    
    reg clk;
    reg reset;
    reg frame_tick;
    reg game_enable;
    reg collision_paddle;
    reg collision_left, collision_right, collision_top;
    reg collision_brick_leftright, collision_brick_topbottom;
    reg miss_ball;
    reg [9:0] paddle_y;

    wire [9:0] ball_x;
    wire [9:0] ball_y;
    
    reg [9:0] prev_x;
    reg [9:0] prev_y;
    
    // Instantiate UUT
    ball_motion uut(
        .clk(clk),
        .reset(reset),
        .frame_tick(frame_tick),
        .game_enable(game_enable),
        .collision_paddle(collision_paddle),
        .collision_left(collision_left),
        .collision_right(collision_right),
        .collision_top(collision_top),
        .collision_brick_leftright(collision_brick_leftright),
        .collision_brick_topbottom(collision_brick_topbottom),
        .miss_ball(miss_ball),
        .paddle_y(paddle_y),
        .ball_x(ball_x),
        .ball_y(ball_y)
    );

    always #5 clk = ~clk;
    
    localparam FRAME_DIV = 8;   // 1 frame_tick every 8 clock cycles
    reg [2:0] frame_cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            frame_cnt  <= 0;
            frame_tick <= 0;
        end else begin
            if (frame_cnt == FRAME_DIV-1) begin
                frame_cnt  <= 0;
                frame_tick <= 1'b1;  // pulse
            end else begin
                frame_cnt  <= frame_cnt + 1'b1;
                frame_tick <= 1'b0;
            end
        end
    end   
    
    // wait exactly one frame update
    task wait_frame;
    begin
        @(posedge clk);              // just to get off of current edge
        @(posedge frame_tick);       // wait for a frame_tick pulse
        @(posedge clk);              // let state update
    end
    endtask
    
    initial begin
        // Initially, no collisions and dx, dy for motion is positive
        clk = 0; reset = 1; game_enable = 1;
        frame_tick = 0;
        collision_paddle = 0;
        collision_left = 0;
        collision_right = 0;
        collision_top = 0;
        collision_brick_leftright = 0;
        collision_brick_topbottom = 0;
        miss_ball = 0;
        paddle_y = 432;
        prev_x = 0;
        prev_y = 0;
        #20;
        
        // Ball moves with no collisions
        reset = 0;
        wait_frame();
        prev_x = ball_x;
        prev_y = ball_y;
                
        // Simulate colliding with right border (flip dx pos to neg)
        collision_right = 1;
        wait_frame();
        collision_right = 0;
        wait_frame();
        wait_frame();
        $display("Right collision: %s", ((ball_x < prev_x) && (ball_y > prev_y)) ? "Passed" : "Failed");
        prev_x = ball_x;
        prev_y = ball_y;        
                
        // Simulate colliding with left border (flip dx neg to pos)
        collision_left = 1;
        wait_frame();
        collision_left = 0;
        wait_frame();
        wait_frame();
        $display("Left collision: %s", ((ball_x > prev_x) && (ball_y > prev_y)) ? "Passed" : "Failed");
        prev_x = ball_x;

        // Simulate colliding with paddle (flip dy neg to pos)   
        collision_paddle = 1;
        wait_frame();
        collision_paddle = 0;
        wait_frame();
        prev_y = ball_y; // because ball jumps to paddle_y when collision happens
        wait_frame();
        $display("Paddle collision: %s", ((ball_x > prev_x) && (ball_y < prev_y)) ? "Passed" : "Failed");
        prev_x = ball_x;
        prev_y = ball_y;     

        // Simulate colliding with top border (flip dy pos to neg)
        collision_top = 1;
        wait_frame();
        collision_top = 0;
        wait_frame();
        wait_frame();
        $display("Top collision: %s", ((ball_x > prev_x) && (ball_y > prev_y)) ? "Passed" : "Failed");
        prev_x = ball_x;
        prev_y = ball_y;  
        
        // Simulate brick collision with left and right sides (flip dx)
        collision_brick_leftright = 1;
        wait_frame();
        collision_brick_leftright = 0;
        wait_frame();
        wait_frame();
        $display("Brick left/right collision: %s", ((ball_x < prev_x) && (ball_y > prev_y)) ? "Passed" : "Failed");
        prev_x = ball_x;
        prev_y = ball_y;         
        
        // Simulate brick collision with top and bottom sides (flip dy)
        collision_brick_topbottom = 1;
        wait_frame();
        collision_brick_topbottom = 0;
        wait_frame();
        wait_frame();
        $display("Brick top/bottom collision: %s", ((ball_x < prev_x) && (ball_y < prev_y)) ? "Passed" : "Failed");
        prev_x = ball_x;
        prev_y = ball_y;    
 
    end
endmodule
