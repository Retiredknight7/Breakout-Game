`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 12:54:43 PM
// Design Name: 
// Module Name: Debounce_tb
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


module Debounce_tb(
    );

  localparam integer N      = 3;            // 2^N = 8
  localparam integer period = 20;           // ns
  localparam integer STABLE = (1<<N) + 2;   // debounce window + 2 sync cycles

  reg  clk_tb;
  reg  noisy_tb;
  wire clean_tb;

  Debounce #(.N(N)) uut(
    .clk  (clk_tb),
    .noisy(noisy_tb),
    .clean(clean_tb)
  );

  // clock
  initial clk_tb = 1'b0;
  always #(period/2) clk_tb = ~clk_tb;

  // helpers
  task automatic wait_cycles(input integer n);
    integer t;
    begin
      for (t = 0; t < n; t = t + 1) begin
        @(posedge clk_tb); #1; // sample after NBAs
      end
    end
  endtask

  // quick bounce train: toggle every cycle for 'toggles' edges
  task automatic bounce(input integer toggles);
    integer t;
    begin
      for (t = 0; t < toggles; t = t + 1) begin
        noisy_tb = ~noisy_tb;
        @(posedge clk_tb); #1;
      end
    end
  endtask

  integer errors = 0;     // init to avoid red X

  initial begin
    noisy_tb = 1'b0;

    // --- Initial settle: expect clean to eventually become 0 ---
    wait_cycles(STABLE);
    if (clean_tb !== 1'b0) begin
      $display("Init FAILED: clean should have settled to 0.");
      errors = errors + 1;
    end else $display("Init passed.");

    // --- Short bounce while target is 0: should NOT change clean ---
    bounce(3);            // < STABLE
    if (clean_tb !== 1'b0) begin
      $display("Short bounce FAILED: clean changed while low.");
      errors = errors + 1;
    end else $display("Short bounce passed.");

    // --- Rise and hold high long enough ---
    noisy_tb = 1'b1;
    wait_cycles(STABLE);
    if (clean_tb !== 1'b1) begin
      $display("Rise stable FAILED: clean didn't go 1.");
      errors = errors + 1;
    end else $display("Rise stable passed.");

    // --- Extra bounces while high: should stay high ---
    bounce(5);
    if (clean_tb !== 1'b1) begin
      $display("High bounce FAILED: clean changed.");
      errors = errors + 1;
    end else $display("High bounce passed.");

    // --- Request a fall and hold long enough ---
    noisy_tb = 1'b0;
    wait_cycles(STABLE);
    if (clean_tb !== 1'b0) begin
      $display("Fall stable FAILED: clean didn't go 0.");
      errors = errors + 1;
    end else $display("Fall stable passed.");

    if (errors == 0) $display("Debounce_tb ALL TESTS PASSED.");
    else             $display("Debounce_tb %0d error(s).", errors);
    $finish;
  end
endmodule
