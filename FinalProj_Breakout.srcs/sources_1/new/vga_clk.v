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
    input clk, reset,
    output reg clk_out
    );
    
    reg [31:0] count;
    localparam DIVISOR = 2;
    
    always @ (posedge(clk), posedge(reset))
    begin
        if (reset == 1'b1)
            count <= 32'b0;
        else if (count == DIVISOR - 1)
            count <= 32'b0;
        else
            count <= count + 1;
    end
    
    always @ (posedge(clk), posedge(reset))
    begin
        if (reset == 1'b1)
            clk_out <= 1'b0;
        else if (count == DIVISOR - 1)
            clk_out <= ~clk_out;
        else
            clk_out <= clk_out;
    end
endmodule
