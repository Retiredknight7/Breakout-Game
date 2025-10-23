`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CSULB
// Engineer: Yshi Blanco
// Create Date: 10/23/2025 01:00:46 AM
// Design Name: VGA Controller
// Module Name: vga_clk
// Project Name: Breakout
// Description: Clock divider to generate 25MHz
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module vga_clk(
    input clk,
    output reg clk_out
    );
    
    reg [1:0] counter = 2'b00;
    
    clk_out = 0;
    
    always @(posedge clk) begin
        if (counter == 2'b11) clk_out = ~clk_out;
        counter = counter + 1;
    end
endmodule
