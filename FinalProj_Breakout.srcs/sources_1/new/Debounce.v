`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2025 
// Design Name: 
// Module Name: Debounce
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


// Simple synchronous debounce: N controls ~filter length (2^N / fclk).
module Debounce #(parameter integer N = 18) (
    input  wire clk,
    input  wire noisy,
    output reg  clean
);
    reg [N-1:0] cnt = 0;
    reg sync0=0, sync1=0;

    always @(posedge clk) begin
        // 2FF sync
        sync0 <= noisy;
        sync1 <= sync0;

        if (clean == sync1) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
            if (&cnt) begin
                clean <= sync1;
            end
        end
    end
endmodule

// Rising-edge one-shot
module EdgeOneShot(
    input  wire clk,
    input  wire din,
    output wire pulse
);
    reg d1=0;
    always @(posedge clk) d1 <= din;
    assign pulse = din & ~d1;
endmodule
