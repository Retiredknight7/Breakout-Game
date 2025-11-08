`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 06:31:12 PM
// Design Name: 
// Module Name: EdgeOneShot_tb
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


module EdgeOneShot_tb(
    );
    // --- Parameters (match your style) ---
  localparam integer period = 20;   // ns
  localparam integer PIPE   = 1;    // 1-cycle latency for your current module

  // --- DUT I/O ---
  reg  clk_tb;
  reg  din_tb;
  wire pulse_tb;

  EdgeOneShot uut (
    .clk   (clk_tb),
    .din   (din_tb),
    .pulse (pulse_tb)
  );

  // --- Clock ---
  initial clk_tb = 1'b0;
  always #(period/2) clk_tb = ~clk_tb;

  // --- Helpers ---
  task automatic wait_cycles(input integer n);
    integer t;
    begin
      for (t = 0; t < n; t = t + 1) begin
        @(posedge clk_tb); #1; // sample after NBAs
      end
    end
  endtask

  integer errors = 0;

  // --- Test sequence ---
  initial begin
    $display("Starting EdgeOneShot_tb (PIPE=%0d)...", PIPE);
    din_tb = 1'b0;

    // idle low
    wait_cycles(1);
    if (pulse_tb !== 1'b0) begin
      $display("FAILED @%0t: idle low, pulse=%b exp=0", $time, pulse_tb);
      errors = errors + 1;
    end else
      $display("passed @%0t: idle low", $time);

    // 1) Rising edge -> expect 1-cycle pulse after PIPE cycles
    din_tb = 1'b1;
    wait_cycles(PIPE);
    if (pulse_tb !== 1'b1) begin
      $display("FAILED @%0t: rising edge, pulse=%b exp=1", $time, pulse_tb);
      errors = errors + 1;
    end else
      $display("passed @%0t: rising edge pulse", $time);

    // pulse must clear next cycle while staying high on din
    wait_cycles(1);
    if (pulse_tb !== 1'b0) begin
      $display("FAILED @%0t: pulse didn't clear", $time);
      errors = errors + 1;
    end else
      $display("passed @%0t: pulse cleared", $time);

    // 2) Falling edge -> no pulse on a falling edge
    din_tb = 1'b0;
    wait_cycles(PIPE);
    if (pulse_tb !== 1'b0) begin
      $display("FAILED @%0t: falling edge created pulse=%b", $time, pulse_tb);
      errors = errors + 1;
    end else
      $display("passed @%0t: falling edge no pulse", $time);

    // 3) Second rising edge -> another single-cycle pulse
    din_tb = 1'b1;
    wait_cycles(PIPE);
    if (pulse_tb !== 1'b1) begin
      $display("FAILED @%0t: 2nd rise, pulse=%b exp=1", $time, pulse_tb);
      errors = errors + 1;
    end else
      $display("passed @%0t: 2nd rise pulse", $time);

    wait_cycles(1); // let it clear
    if (pulse_tb !== 1'b0) begin
      $display("FAILED @%0t: pulse didn't clear after 2nd rise", $time);
      errors = errors + 1;
    end else
      $display("passed @%0t: pulse cleared after 2nd rise", $time);

    // --- Report ---
    if (errors == 0) $display("EdgeOneShot_tb ALL TESTS PASSED.");
    else             $display("EdgeOneShot_tb %0d error(s).", errors);
    $finish;
  end
endmodule
