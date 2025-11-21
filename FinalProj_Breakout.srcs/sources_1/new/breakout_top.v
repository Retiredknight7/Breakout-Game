`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 11/07/2025 03:44:26 PM
// Design Name: 
// Module Name: breakout_top
// Description: 
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module breakout_top(
    input  wire        clk,         // 100 MHz board clock
    input  wire        reset,       // pushbutton (active-high)
    input  wire        move_left,   // BTNL
    input  wire        move_right,  // BTNR

    // VGA outputs
    output wire        hsync,
    output wire        vsync,
    output wire [11:0] rgb,

    // 7-seg score display
    output wire [6:0]  SEG,
    output wire [7:0]  AN,
    output wire        DP

);

    // --- Internal wires ---
    wire collision_left, collision_right, collision_top;
    wire collision_paddle, collision_brick_leftright, collision_brick_topbottom;
    wire miss_ball;
    wire [9:0] paddle_x, ball_x, ball_y;
    wire [6:0] hit_idx;

    // --- Pixel clock to be used for the paddle control and score keeper
    wire clk_pix;
    vga_clk clkgen (
        .clk     (clk),      // 100 MHz in
        .reset   (reset),
        .clk_out (clk_pix)   // ~25 MHz out with DIVISOR=2 in your vga_clk
    );

    // Reset synchronized to pixel clock (2-FF sync)
    reg [1:0] rst_sync;
    always @(posedge clk_pix or posedge reset) begin
        if (reset) rst_sync <= 2'b11;
        else       rst_sync <= {1'b0, rst_sync[1]};
    end
    wire rst_pix = rst_sync[0];

    // --- Instantiate VGA Controller Module ---    
    vga_controller vga (
        .clk(clk_pix),
        .reset(rst_pix),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .bricks(active_bricks),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );
    
    // frame_tick in pixel domain
    reg vsync_d;
    always @(posedge clk_pix or posedge rst_pix) begin
        if (rst_pix) vsync_d <= 1'b0;
        else         vsync_d <= vsync;
    end
    wire frame_tick = vsync & ~vsync_d;  // 1-cycle pulse per frame

    // --- Instantiate Paddle Module ---
    wire [9:0] paddle_y = 432;

    wire left_db, right_db;
    Debounce dbL (.clk(clk_pix), .noisy(move_left),  .clean(left_db));
    Debounce dbR (.clk(clk_pix), .noisy(move_right), .clean(right_db));

    reg left_d, right_d;
    always @(posedge clk_pix or posedge rst_pix) begin
        if (rst_pix) begin
            left_d  <= 1'b0;
            right_d <= 1'b0;
        end else begin
            left_d  <= left_db;
            right_d <= right_db;
        end
    end

    wire move_left_hold   = left_db;
    wire move_right_hold  = right_db;
    wire move_left_step   = left_db  & ~left_d;   // press edge
    wire move_right_step  = right_db & ~right_d;
 
    paddle_control paddle_inst (
        .clk            (clk_pix),
        .reset          (rst_pix),
        .frame_tick     (frame_tick),
        .move_left_hold (move_left_hold),
        .move_right_hold(move_right_hold),
        .move_left_step (move_left_step),
        .move_right_step(move_right_step),
        .paddle_x       (paddle_x),
        .paddle_y       (paddle_y)   // unused; Y fixed above
    );

    // --- Instantiate Collision Detection ---
    collision_detection coll_inst (
        .ball_x(ball_x),
        .ball_y(ball_y),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .active_bricks(active_bricks),
        .collision_left(collision_left),
        .collision_right(collision_right),
        .collision_top(collision_top),
        .collision_paddle(collision_paddle),
        .collision_brick_leftright(collision_brick_leftright),
        .collision_brick_topbottom(collision_brick_topbottom),
        .hit_idx(hit_idx),
        .miss_ball(miss_ball)
    );
    
    // Updating brick grid
    reg [76:0] active_bricks;

    always @(posedge clk_pix or posedge rst_pix) begin
      if (rst_pix) begin
        active_bricks <= {77{1'b1}};
      end else begin
        if (brick_hit_pix_pulse)
          active_bricks[hit_idx] <= 1'b0;
      end
    end

    // --- Instantiate Ball Motion ---
    ball_motion ball_inst (
        .clk(clk_pix),
        .reset(rst_pix),
        .frame_tick(frame_tick),
        .collision_left(collision_left),
        .collision_right(collision_right),
        .collision_top(collision_top),
        .collision_paddle(collision_paddle),
        .collision_brick_leftright(collision_brick_leftright),
        .collision_brick_topbottom(collision_brick_topbottom),
        .miss_ball(miss_ball),
        .ball_x(ball_x),
        .ball_y(ball_y)
    );
    
    // --- Instantiate ScoreKeeper module ---
    wire brick_hit_raw = collision_brick_leftright | collision_brick_topbottom;
    
    reg brick_hit_d;
    always @(posedge clk_pix or posedge rst_pix) begin
      if (rst_pix) brick_hit_d <= 1'b0;
      else         brick_hit_d <= brick_hit_raw;
    end
    
    wire brick_hit_pix_pulse = brick_hit_raw & ~brick_hit_d;

    reg hit_meta, hit_sync, hit_sync_d;
    always @(posedge clk or posedge reset) begin
      if (reset) begin
        hit_meta   <= 1'b0;
        hit_sync   <= 1'b0;
        hit_sync_d <= 1'b0;
      end else begin
        hit_meta   <= brick_hit_pix_pulse; // async input sampled by clk
        hit_sync   <= hit_meta;            // 2-FF synchronizer
        hit_sync_d <= hit_sync;            // delay for edge detect
      end
    end
    
    wire score_hit_pulse = hit_sync & ~hit_sync_d; 
    
    ScoreKeeper score_i (
        .clk100mhz (clk),
        .HIT       (score_hit_pulse),
        .RESET     (rst_pix),     // or hook a dedicated score-reset button
        .SEG       (SEG),
        .AN        (AN),
        .DP        (DP)
    );

endmodule
