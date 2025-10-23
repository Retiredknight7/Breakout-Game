`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2025 08:00:34 PM
// Design Name: 
// Module Name: SevenSegMux
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


// Replace your SevenSegMux with this version.
// Set LSB_AT_AN0 = 1 if least-significant digit is at AN[0] (rightmost on Nexys).
// Set LSB_AT_AN0 = 0 if your wiring/expectation is the opposite.
module SevenSegMux #(
    parameter integer NUM_DIGITS  = 8,
    parameter         LSB_AT_AN0  = 1   // <- try flipping this to 0 if digits look reversed
)(
    input  wire clk,
    input  wire scan_tick,
    input  wire [NUM_DIGITS*4-1:0] bcd_vec,     // {dN-1 ... d1 d0}, d0 = LSD
    output wire [6:0] seg,                      // a..g, active-low (common-anode)
    output reg  [NUM_DIGITS-1:0] an,            // anodes, active-low
    output wire dp
);
    localparam integer IDXW = $clog2(NUM_DIGITS);
    reg [IDXW-1:0] idx = 0;

    // advance currently active digit
    always @(posedge clk) begin
        if (scan_tick) idx <= (idx == NUM_DIGITS-1) ? 0 : idx + 1'b1;
    end

    // Map scan index to which nibble we show:
    // If LSB_AT_AN0=1: AN[0] shows d0 (LSD), AN[1] shows d1, ...
    // If LSB_AT_AN0=0: AN[0] shows dN-1 (MSD), AN[1] shows dN-2, ...
    wire [IDXW-1:0] nidx = LSB_AT_AN0 ? idx : (NUM_DIGITS-1-idx);
    wire [3:0] cur_bcd = bcd_vec[nidx*4 +: 4];

    // Decode to segments a..g (active-low)
    SegDecoder dec (.bcd(cur_bcd), .seg(seg));

    // One-hot (active-low) anode select
    integer k;
    always @* begin
        an = {NUM_DIGITS{1'b1}};
        an[idx] = 1'b0;  // enables the physical AN[idx]
    end

    assign dp = 1'b1; // decimal point off
 endmodule
 
    // 7-seg decoder for common-anode (active-low): outputs {a,b,c,d,e,f,g}
module SegDecoder(
    input  wire [3:0] bcd,
    output reg  [6:0] seg
);
    always @* begin
        case (bcd)
            4'd0: seg = 7'b0000001;
            4'd1: seg = 7'b1001111;
            4'd2: seg = 7'b0010010;
            4'd3: seg = 7'b0000110;
            4'd4: seg = 7'b1001100;
            4'd5: seg = 7'b0100100;
            4'd6: seg = 7'b0100000;
            4'd7: seg = 7'b0001111;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0000100;
            default: seg = 7'b1111111; // blank/off
        endcase
    end
endmodule

