`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: : 04/12/2023 010:19:11 AM
// Design Name: 
// Module Name: ClockDivider
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


module ClockDivider #(parameter integer DIVIDE = 12500) (
    input  wire clk,
    output reg  tick   // initialize tick to 0
);
    localparam integer W = $clog2(DIVIDE);
    reg [W-1:0] cnt = 0;
    
    // give tick a defined power-up value for sim & synth
    initial tick = 1'b0;

    always @(posedge clk) begin
        if (cnt == DIVIDE-1) begin
            cnt  <= 0;
            tick <= 1'b1;
        end else begin
            cnt  <= cnt + 1'b1;
            tick <= 1'b0;
        end
    end
endmodule
