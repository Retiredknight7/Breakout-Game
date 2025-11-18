`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Brayan Alejandro Fuentes Vargas
// 
// Create Date: 10/22/2025
// Design Name: 
// Module Name: BcdCounter
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
// Holds score as BCD digits [d0..dN-1], d0 = least significant.
// inc: one pulse => +1; clr: clear all digits to 0.
module BcdCounter #(parameter integer NUM_DIGITS = 8) (
    input  wire clk,
    input  wire inc,
    input  wire clr,
    output reg  [NUM_DIGITS*4-1:0] digits
);
    integer i;

    // ---- Moved out of the always block ----
    reg carry;
    reg [NUM_DIGITS*4-1:0] next;

    // helper: access nibble i
    function [3:0] get_digit(input [NUM_DIGITS*4-1:0] v, input integer idx);
        get_digit = v[idx*4 +: 4];
    endfunction

    function [NUM_DIGITS*4-1:0] set_digit(
        input [NUM_DIGITS*4-1:0] v, input integer idx, input [3:0] val
    );
        reg [NUM_DIGITS*4-1:0] t;
        begin
            t = v;
            t[idx*4 +: 4] = val;
            set_digit = t;
        end
    endfunction

    initial digits = {NUM_DIGITS{4'd0}};

    always @(posedge clk) begin
        if (clr) begin
            digits <= {NUM_DIGITS{4'd0}};
        end else if (inc) begin
            // start from current digits
            next  = digits;
            carry = 1'b1; // add 1

            // ripple carry in BCD space
            for (i = 0; i < NUM_DIGITS; i = i + 1) begin
                if (carry) begin
                    if (get_digit(next, i) == 4'd9) begin
                        next  = set_digit(next, i, 4'd0);
                        carry = 1'b1;
                    end else begin
                        next  = set_digit(next, i, get_digit(next, i) + 4'd1);
                        carry = 1'b0;
                    end
                end
            end
            digits <= next; // wraps to 0..0 on overflow naturally
        end
    end
endmodule

