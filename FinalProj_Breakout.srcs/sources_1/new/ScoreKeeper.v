`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Brayan Alejandro Fuentes Vargas
// 
// Create Date: 10/23/2025 12:57:01 PM
// Design Name: 
// Module Name: ScoreKeeper
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

// ============================================================
// ScoreKeeper: Score display w/ HIT increment and RESET clear
// Board: Nexys A7-100T (8-digit 7-seg, common-anode, active-low anodes)
// ============================================================
module ScoreKeeper(
    input  wire clk100mhz,     // 100 MHz board clock
    input  wire HIT,           // button or game pulse: increment score by 1
    input  wire RESET,         // button: clear score to 0
    output wire [6:0] SEG,     // segments a..g (active-low for common-anode mapping)
    output wire [7:0] AN,      // anodes AN0..AN7 (active-low select)
    output wire DP             // decimal point (kept off: 1)
);
    localparam integer NUM_DIGITS = 8;           // Nexys A7 has 8 digits
    localparam integer PER_DIGIT_REFRESH_HZ = 1000; // ?1kHz per digit (nice, flicker-free)

    // --- Debounce & one-shot the buttons ---
    wire hit_db, reset_db;
    Debounce #(.N(18)) db_hit   (.clk(clk100mhz), .noisy(HIT),   .clean(hit_db));
    Debounce #(.N(18)) db_reset (.clk(clk100mhz), .noisy(RESET), .clean(reset_db));

    wire hit_pulse, reset_pulse;
    EdgeOneShot os_hit   (.clk(clk100mhz), .din(hit_db),   .pulse(hit_pulse));
    EdgeOneShot os_reset (.clk(clk100mhz), .din(reset_db), .pulse(reset_pulse));

    // --- Score counter in BCD (one nibble per digit) ---
    wire [NUM_DIGITS*4-1:0] bcd_digits;
    BcdCounter #(.NUM_DIGITS(NUM_DIGITS)) score_cnt (
        .clk     (clk100mhz),
        .inc     (hit_pulse),
        .clr     (reset_pulse),
        .digits  (bcd_digits)
    );

    // --- Create a scan tick for the display mux ---
    // total refresh = NUM_DIGITS * PER_DIGIT_REFRESH_HZ
    localparam integer SCAN_HZ = NUM_DIGITS * PER_DIGIT_REFRESH_HZ;
    localparam integer DIVIDE  = 100_000_000 / SCAN_HZ; // 100MHz / (8*1k) = 12_500
    wire scan_tick;
    ClockDivider #(.DIVIDE(DIVIDE)) scan_div (.clk(clk100mhz), .tick(scan_tick));

    // --- Multiplex BCD digits onto 7-seg display ---
    SevenSegMux #(.NUM_DIGITS(NUM_DIGITS)) disp (
        .clk       (clk100mhz),
        .scan_tick (scan_tick),
        .bcd_vec   (bcd_digits),
        .seg       (SEG),
        .an        (AN),
        .dp        (DP)
    );

endmodule

