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
    input clk, reset,
    output wire hsync, vsync, video_on,
    output reg [9:0] pixel_x, pixel_y
    );
    
    // Horizontal timing constants
    localparam ACTIVE_HOR = 640;
    localparam FRONTP_HOR = 16;
    localparam SYNCPULSE_HOR = 96;
    localparam BACKP_HOR = 48;
    localparam TOTAL_HOR = ACTIVE_HOR + FRONTP_HOR + SYNCPULSE_HOR + BACKP_HOR - 1;
    
    // Vertical timing constants
    localparam ACTIVE_VERT = 480;
    localparam FRONTP_VERT = 10;
    localparam SYNCPULSE_VERT = 2;
    localparam BACKP_VERT = 33;
    localparam TOTAL_VERT = ACTIVE_VERT + FRONTP_VERT + SYNCPULSE_VERT + BACKP_VERT - 1;
    
    // Tracking pixels
    always @(posedge(clk), posedge(reset)) begin
        if (reset == 1) begin
            pixel_x <= 10'b0000000000;
            pixel_y <= 10'b0000000000;
        end else if (pixel_x == TOTAL_HOR) begin
            pixel_x <= 10'b0000000000;
            if (pixel_y == TOTAL_VERT) begin
                pixel_y <= 10'b0000000000;
            end else begin
                pixel_y <= pixel_y + 1;
            end
        end else begin
            pixel_x <= pixel_x + 1;
        end
    end
    
    // active video flag (useful for your pixel generator to blank RGB)
    assign video_on = (pixel_x < ACTIVE_HOR) && (pixel_y < ACTIVE_VERT);

    // Frequency generation
    assign hsync = ~((pixel_x >= (ACTIVE_HOR + FRONTP_HOR)) &&
                     (pixel_x <  (ACTIVE_HOR + FRONTP_HOR + SYNCPULSE_HOR)));

    assign vsync = ~((pixel_y >= (ACTIVE_VERT + FRONTP_VERT)) &&
                     (pixel_y <  (ACTIVE_VERT + FRONTP_VERT + SYNCPULSE_VERT)));
endmodule
