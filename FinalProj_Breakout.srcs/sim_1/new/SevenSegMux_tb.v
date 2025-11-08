`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 11:07:02 AM
// Design Name: 
// Module Name: SevenSegMux_tb
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


module SevenSegMux_tb(
    );
  // Parameters (pick small for quick sim)
  localparam integer NUM_DIGITS = 4;

  // Create registers and wires
  reg  clk_tb;
  reg  scan_tick_tb;
  reg  [NUM_DIGITS*4-1:0] bcd_vec_tb;  // {d3,d2,d1,d0}
  wire [6:0] seg_tb;
  wire [NUM_DIGITS-1:0] an_tb;
  wire dp_tb;

  // Duration for each step
  localparam period = 20;

  // Instantiate the module (default LSB_AT_AN0 = 1)
  SevenSegMux #(.NUM_DIGITS(NUM_DIGITS), .LSB_AT_AN0(1)) uut (
    .clk(clk_tb),
    .scan_tick(scan_tick_tb),
    .bcd_vec(bcd_vec_tb),
    .seg(seg_tb),
    .an(an_tb),
    .dp(dp_tb)
  );

  // Free-running clock
  initial clk_tb = 0;
  always #(period/2) clk_tb = ~clk_tb;

  // Golden model for decoder (same mapping as SegDecoder)
  function automatic [6:0] expect_seg(input [3:0] b);
    case (b)
      4'd0: expect_seg = 7'b0000001;
      4'd1: expect_seg = 7'b1001111;
      4'd2: expect_seg = 7'b0010010;
      4'd3: expect_seg = 7'b0000110;
      4'd4: expect_seg = 7'b1001100;
      4'd5: expect_seg = 7'b0100100;
      4'd6: expect_seg = 7'b0100000;
      4'd7: expect_seg = 7'b0001111;
      4'd8: expect_seg = 7'b0000000;
      4'd9: expect_seg = 7'b0000100;
      default: expect_seg = 7'b1111111;
    endcase
  endfunction

  // Expected one-hot (active-low) anode from index
  function automatic [NUM_DIGITS-1:0] expect_an(input integer idx);
    integer j;
    begin
      expect_an = {NUM_DIGITS{1'b1}};
      if (idx >= 0 && idx < NUM_DIGITS)
        expect_an[idx] = 1'b0;
    end
  endfunction

  // Helper to slice current nibble for LSB_AT_AN0=1 mapping
  function automatic [3:0] get_nibble(input integer nidx, input [NUM_DIGITS*4-1:0] vec);
    get_nibble = vec[nidx*4 +: 4];
  endfunction

  integer step;
  integer idx;     // current scan index we expect
  reg [3:0] cur_bcd;
  reg [6:0] seg_exp;
  reg [NUM_DIGITS-1:0] an_exp;

  initial begin
    scan_tick_tb = 1'b0;
    bcd_vec_tb   = {4'd3,4'd2,4'd1,4'd0}; // AN0=0, AN1=1, AN2=2, AN3=3
    step         = 0;
    idx          = 0;
    cur_bcd      = 4'd0;
    seg_exp      = 7'b1111111;
    an_exp       = {NUM_DIGITS{1'b1}};
  end
  
  
  initial begin
    // Give time for initial idx=0 to propagate
    #(period);

    // Check a few full scan cycles
    for (step = 0; step < NUM_DIGITS*3; step = step + 1) begin
      // Expected index with LSB_AT_AN0=1 increments 0,1,2,3,0,1,...
      idx      = step % NUM_DIGITS;
      cur_bcd  = get_nibble(idx, bcd_vec_tb);
      seg_exp  = expect_seg(cur_bcd);
      an_exp   = expect_an(idx);

      // Sample current outputs (after last edge)
      if (seg_tb == seg_exp && an_tb == an_exp && dp_tb == 1'b1)
        $display("scan%0d idx=%0d bcd=%0d seg=%07b an=%b passed.",
                 step, idx, cur_bcd, seg_tb, an_tb);
      else
        $display("scan%0d idx=%0d FAILED: bcd=%0d seg=%07b(exp=%07b) an=%b(exp=%b) dp=%b(exp=1)",
                 step, idx, cur_bcd, seg_tb, seg_exp, an_tb, an_exp, dp_tb);

      // Pulse scan_tick for the next idx advancement
      scan_tick_tb = 1'b1;
      #(period);
      scan_tick_tb = 1'b0;
      #(period); // allow some time before next check
    end

    $finish;
  end
endmodule
