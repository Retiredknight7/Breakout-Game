`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 12:25:06 PM
// Design Name: 
// Module Name: ClockDivider_tb
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


module ClockDivider_tb(
    );
    // --- sim params ---
  localparam integer period = 10;   // ns
  localparam integer DIV    = 4;    // small for fast simulation

  // --- DUT I/O (tb side) ---
  reg  clk_tb;
  wire tick_tb;

  // --- DUT ---
  ClockDivider #(.DIVIDE(DIV)) uut (
    .clk  (clk_tb),
    .tick (tick_tb)
  );

  // --- clock ---
  initial clk_tb = 1'b0;
  always #(period/2) clk_tb = ~clk_tb;

  // --- helper: sample after NBAs on each posedge ---
  task automatic step_clk;
    begin
      @(posedge clk_tb); #1;
    end
  endtask

  integer cyc = 0;
  integer errors = 0;

  initial begin
    // give the DUT one cycle to initialize tick <= 0
    step_clk();

    // Check a few periods
    // Expect: tick == 1 exactly when cyc is a multiple of DIV
    for (cyc = 1; cyc <= 3*DIV; cyc = cyc + 1) begin
      // check current cycle
      if ((cyc % DIV) == 0) begin
        if (tick_tb !== 1'b1) begin
          $display("cycle %0d FAILED: tick should be 1.", cyc);
          errors = errors + 1;
        end
      end else begin
        if (tick_tb !== 1'b0) begin
          $display("cycle %0d FAILED: tick should be 0.", cyc);
          errors = errors + 1;
        end
      end

      // advance to next cycle
      step_clk();
    end

    if (errors == 0) $display("ClockDivider_tb ALL TESTS PASSED.");
    else             $display("ClockDivider_tb %0d error(s).", errors);
    $finish;
  end
    /*
    // Smaller divide for short sim
  localparam integer DIVIDE = 4;
  localparam integer period = 20;

  reg  clk_tb;
  wire tick_tb;

  // DUT instantiation
  ClockDivider #(.DIVIDE(DIVIDE)) uut (
    .clk (clk_tb),
    .tick(tick_tb)
  );

  // Clock generator
  initial clk_tb = 1'b0;
  always #(period/2) clk_tb = ~clk_tb;

  integer cyc;
  integer errors;

  initial begin
    cyc    = 0;
    errors = 0;

    // Give DUT time to initialize
    #(period);
    $display("Starting ClockDivider test with DIVIDE=%0d", DIVIDE);

    // Observe several full cycles
    repeat (5*DIVIDE) begin
      @(posedge clk_tb);
      #1; // wait one delta-time for NBA updates

      // tick should be high only on wrap edge
      if ((cyc % DIVIDE) == (DIVIDE-1)) begin
        if (tick_tb !== 1'b1) begin
          $display("cycle %0d FAILED: tick should be 1.", cyc);
          errors = errors + 1;
        end else begin
          $display("cycle %0d passed: tick=1 on wrap.", cyc);
        end
      end else begin
        if (tick_tb !== 1'b0) begin
          $display("cycle %0d FAILED: tick should be 0.", cyc);
          errors = errors + 1;
        end
      end

      cyc = cyc + 1;
    end

    if (errors == 0)
      $display("ClockDivider_tb ALL TESTS PASSED.");
    else
      $display("ClockDivider_tb %0d error(s).", errors);

    $finish;
  end
  */
endmodule
