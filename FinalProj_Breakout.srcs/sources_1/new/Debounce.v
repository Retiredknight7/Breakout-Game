`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Brayan Alejandro Fuentes Vargas
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


// Simple synchronous debounce: N controls hold time (~2^N / fclk)
module Debounce #(parameter integer N = 18) (
    input  wire clk,
    input  wire noisy,
    output reg  clean
);
    reg        sync0, sync1;
    reg [N-1:0] cnt;

    always @(posedge clk) begin
        // 2FF synchronizer
        sync0 <= noisy;
        sync1 <= sync0;

        // counter runs only while input != clean
        if (clean == sync1) begin
            cnt <= {N{1'b0}};
        end else begin
            cnt <= cnt + {{(N-1){1'b0}}, 1'b1};
            if (&cnt) begin
                clean <= sync1;      // accept new state after stable period
                cnt   <= {N{1'b0}};
            end
        end
    end
endmodule

