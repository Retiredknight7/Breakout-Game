`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CSULB
// Engineer: Yshi Blanco
// Create Date: 10/23/2025 01:04:48 AM
// Design Name: VGA Controller
// Module Name: vga_clk_tb
// Project Name: Breakout
// Description: Testbench for clock divider
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module vga_clk_tb(
    );
    
    reg clk_tb, reset_tb;
    wire clk_out_tb;
    
    vga_clk uut(.clk(clk_tb), .reset(reset_tb), .clk_out(clk_out_tb));
    
    always #5 clk_tb = ~clk_tb;
    
    initial begin
        clk_tb = 0; reset_tb = 1;
        #20;
        reset_tb = 0;
        #100;
    end
endmodule
