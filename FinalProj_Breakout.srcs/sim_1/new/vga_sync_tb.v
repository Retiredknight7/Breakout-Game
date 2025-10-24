`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 07:22:13 PM
// Design Name: 
// Module Name: vga_sync_tb
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


module vga_sync_tb(
    );
    
    reg clk_tb, reset_tb;
    wire clk_out_tb, hsync_tb, vsync_tb;
    wire [9:0] pixel_x_tb, pixel_y_tb; 
    
    vga_clk clk(.clk(clk_tb), .reset(reset_tb), .clk_out(clk_out_tb));
    vga_sync uut(.clk(clk_out_tb), .reset(reset_tb), .hsync(hsync_tb), .vsync(vsync_tb), .pixel_x(pixel_x_tb), .pixel_y(pixel_y_tb));
    
    always #5 clk_tb = ~clk_tb;
    
    initial begin
        clk_tb = 0; reset_tb = 1;
        #20;
        reset_tb = 0;
        #20000000;
    end
    
endmodule
