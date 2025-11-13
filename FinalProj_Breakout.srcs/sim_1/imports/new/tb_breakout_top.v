`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 03:45:49 PM
// Module Name: tb_breakout_top
//////////////////////////////////////////////////////////////////////////////////

module tb_breakout_top;
    reg clk = 0;
    reg reset = 1;
    reg move_left = 0;
    reg move_right = 0;

    wire [9:0] ball_x, ball_y, paddle_x;

    breakout_top uut (
        .clk(clk),
        .reset(reset),
        .move_left(move_left),
        .move_right(move_right),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .paddle_x(paddle_x)
    ); 

    // Generate clock (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $monitor("Time=%0t | Ball=(%d,%d) | Paddle=%d | Left=%b | Right=%b", 
                 $time, ball_x, ball_y, paddle_x, move_left, move_right);
    end

    // Main simulation sequence
    initial begin
        // Apply reset
        #10 reset = 0;
        #20 move_right = 1;
        #100 move_right = 0;
        #50 move_left = 1;
        #100 move_left = 0;

        // Run simulation for a while
        #300;
        $finish;
    end
endmodule
