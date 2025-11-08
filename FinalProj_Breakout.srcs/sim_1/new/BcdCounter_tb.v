`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 12:44:41 PM
// Design Name: 
// Module Name: BcdCounter_tb
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


module BcdCounter_tb(
    );
    localparam integer NUM_DIGITS = 2;   // 00..99 for quick wrap
  localparam integer period     = 2;   // 2ns -> fast simulation

  reg  clk_tb;
  reg  inc_tb;
  reg  clr_tb;
  wire [NUM_DIGITS*4-1:0] digits_tb;

  // DUT
  BcdCounter #(.NUM_DIGITS(NUM_DIGITS)) uut(
    .clk   (clk_tb),
    .inc   (inc_tb),
    .clr   (clr_tb),
    .digits(digits_tb)
  );

  // clock
  initial clk_tb = 1'b0;
  always #(period/2) clk_tb = ~clk_tb;

  // helper: integer -> {d1,d0} (d0 = LSD)
  function automatic [NUM_DIGITS*4-1:0] to_bcd_vec(input integer value);
    integer j, t;
    reg [NUM_DIGITS*4-1:0] v;
    begin
      v = {NUM_DIGITS{4'd0}};
      t = value;
      for (j = 0; j < NUM_DIGITS; j = j + 1) begin
        v[j*4 +: 4] = t % 10;
        t = t / 10;
      end
      to_bcd_vec = v;
    end
  endfunction

  integer exp_val;
  integer i;               // loop counter (initialized to avoid red X)
  reg [31:0] i_tb;         // mirrored copy to view cleanly in waveform
  integer errors;

  initial begin
    // explicit init to avoid startup Xs
    inc_tb   = 1'b0;
    clr_tb   = 1'b1;
    exp_val  = 0;
    i        = 0;
    i_tb     = 0;
    errors   = 0;

    // deassert clear and check zeros
    @(posedge clk_tb);
    clr_tb = 1'b0;
    @(posedge clk_tb);
    if (digits_tb !== to_bcd_vec(0)) begin
      $display("After clear FAILED: digits=%h exp=%h", digits_tb, to_bcd_vec(0));
      errors = errors + 1;
    end else begin
      $display("After clear passed.");
    end

    // Count 130 increments to exercise 09->10, 19->20, 99->00 wrap
    for (i = 1; i <= 130; i = i + 1) begin
      i_tb = i;                 // mirror for waveform
      inc_tb = 1'b1; @(posedge clk_tb);
      inc_tb = 1'b0; @(posedge clk_tb);

      exp_val = (exp_val + 1) % 100;  // two digits -> modulo 100
      if (digits_tb !== to_bcd_vec(exp_val)) begin
        $display("INC %0d FAILED: digits=%h exp=%h", i, digits_tb, to_bcd_vec(exp_val));
        errors = errors + 1;
      end
    end

    if (errors == 0) $display("BcdCounter_tb ALL TESTS PASSED.");
    else             $display("BcdCounter_tb %0d error(s).", errors);
    $finish;
  end
endmodule
