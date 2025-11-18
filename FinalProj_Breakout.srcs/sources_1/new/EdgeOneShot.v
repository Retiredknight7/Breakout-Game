`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Brayan Alejandro Fuentes Vargas
// 
// Create Date: 11/16/2025 09:13:33 PM
// Design Name: 
// Module Name: EdgeOneShot
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


module EdgeOneShot(
    input  wire clk,
    input  wire din,
    output wire pulse
);
  reg d1 = 1'b0;      // previous din
  reg pulse_r = 1'b0; // registered pulse

  always @(posedge clk) begin
    pulse_r <= din & ~d1; // goes high for 1 cycle on rising edge
    d1      <= din;       // capture current din for next cycle
  end

  assign pulse = pulse_r;
endmodule
