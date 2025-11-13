`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 03:14:39 PM
// Design Name: 
// Module Name: game_fsm_tb
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

module game_fsm_tb;

  // Inputs
  reg clk;
  reg reset;
  reg start;
  reg hit_brick;
  reg hit_wall;
  reg miss_ball;
  reg [3:0] lives;
  reg bricks_left;

  // Outputs
  wire display_start;
  wire display_win;
  wire display_gameover;
  wire reflect_ball;
  wire reset_ball;
  wire score_enable;
  wire game_active;

  // Instantiate the Unit Under Test (UUT)
  game_fsm uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .hit_brick(hit_brick),
    .hit_wall(hit_wall),
    .miss_ball(miss_ball),
    .lives(lives),
    .bricks_left(bricks_left),
    .display_start(display_start),
    .display_win(display_win),
    .display_gameover(display_gameover),
    .reflect_ball(reflect_ball),
    .reset_ball(reset_ball),
    .score_enable(score_enable),
    .game_active(game_active)
  );

  // Clock generation
  always #5 clk = ~clk;

  // State name helper task
  task print_state;
    case (uut.current_state)
      3'b000: $write("IDLE       ");
      3'b001: $write("PLAY       ");
      3'b010: $write("HIT_BRICK  ");
      3'b011: $write("HIT_WALL   ");
      3'b100: $write("MISS_BALL  ");
      3'b101: $write("WIN        ");
      3'b110: $write("GAME_OVER  ");
      default: $write("UNKNOWN    ");
    endcase
  endtask

    // Apply stimulus
  initial begin
    // Initialize inputs
    clk = 0;
    reset = 1;
    start = 0;
    hit_brick = 0;
    hit_wall = 0;
    miss_ball = 0;
    lives = 3;
    bricks_left = 1;

    // Start monitoring output changes
    $display("Time(ns)\tState\t\tstart hit_brick hit_wall miss_ball bricks_left lives | display_start display_win display_gameover reflect_ball reset_ball score_enable game_active");
    $display("---------------------------------------------------------------------------------------------------------");

    // Monitor on every state or input change
    forever begin
      @(uut.current_state or start or hit_brick or hit_wall or miss_ball or bricks_left or lives);
      $write("%0t\t", $time);
      print_state;
      $display("\t%b\t%b\t%b\t%b\t%b\t%d\t| %b\t\t%b\t\t%b\t\t%b\t\t%b\t\t%b\t\t%b",
        start, hit_brick, hit_wall, miss_ball, bricks_left, lives,
        display_start, display_win, display_gameover, reflect_ball, reset_ball, score_enable, game_active);
    end
  end

  // Stimulus sequence
  initial begin
    #10 reset = 0;  // Release reset
    #10 start = 1;  // Start game
    #10 start = 0;

    // Hit brick
    #20 hit_brick = 1; #10 hit_brick = 0;

    // Hit wall
    #20 hit_wall = 1; #10 hit_wall = 0;

    // Miss ball (still lives left)
    #20 miss_ball = 1; #10 miss_ball = 0;

    // Win (no bricks left)
    #30 bricks_left = 0;

    // Reset to new game
    #20 reset = 1; #10 reset = 0;

    // Lose all lives
    #20 reset = 1; #10 reset = 0;
    bricks_left = 1;
    lives = 0;
    #20 miss_ball = 1; #10 miss_ball = 0;

    #50 $finish;
  end

endmodule
