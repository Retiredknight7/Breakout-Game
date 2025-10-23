`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CSULB
// Engineer: Yshi Blanco
// Create Date: 10/22/2025 12:47:15 PM
// Design Name: VGA Controller
// Module Name: vga_sync
// Project Name: Breakout
// Description: Frequency generator that determines the timing of writing pixels
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module vga_sync(
    input wire clk, reset,
    output wire hsync, vsync, video_on, p_tick,
    output wire [9:0] pixel_x, pixel_y
    );
    
    // Horizontal timing constants
    localparam ACTIVE_HOR = 640;
    localparam FRONTP_HOR = 16;
    localparam SYNCPULSE_HOR = 96;
    localparam BACKP_HOR = 48;
    
    // Vertical timing constants
    localparam ACTIVE_VERT = 480;
    localparam FRONTP_VERT = 10;
    localparam SYNCPULSE_VERT = 2;
    localparam BACKP_VERT = 33;
    
    always @(posedge clk) begin
        
    end
endmodule
