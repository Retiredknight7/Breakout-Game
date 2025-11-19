`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 03:44:26 PM
// Design Name: 
// Module Name: breakout_top
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
    // =================================================================
    // 0) Pixel clock generation (one place only)
    //     Your vga_clk is a simple divider: ports (clk, reset, clk_out)
    // =================================================================
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

    // =================================================================
    // 1) Controls: debounce in pixel domain (hold + one-shot step)
    // =================================================================
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

    // =================================================================
    // 2) VGA controller + frame_tick (rising edge of vsync)
    // =================================================================
    wire        video_on;
    wire [9:0]  pixel_paddle_x;
    wire [9:0]  pixel_ball_x, pixel_ball_y;
    wire [9:0]  paddle_y = 10'd460;   // near bottom

    vga_controller vga_i (
        .clk      (clk_pix),          // USE pixel clock (no local clocking inside)
        .reset    (rst_pix),
        .paddle_x (pixel_paddle_x),
        .paddle_y (paddle_y),
        .ball_x   (pixel_ball_x),
        .ball_y   (pixel_ball_y),
        .hsync    (hsync),
        .vsync    (vsync),
        .video_on (video_on),
        .rgb      (rgb)
    );

    // frame_tick in pixel domain
    reg vsync_d;
    always @(posedge clk_pix or posedge rst_pix) begin
        if (rst_pix) vsync_d <= 1'b0;
        else         vsync_d <= vsync;
    end
    wire frame_tick = vsync & ~vsync_d;  // 1-cycle pulse per frame

    // =================================================================
    // 3) Paddle control (frame-locked movement)
    // =================================================================
    paddle_control #(
        .H_VISIBLE    (640),
        .PADDLE_W     (80),
        .PADDLE_Y     (460),
        .PADDLE_SPEED (8)
    ) paddle_inst (
        .clk            (clk_pix),
        .reset          (rst_pix),
        .frame_tick     (frame_tick),
        .move_left_hold (move_left_hold),
        .move_right_hold(move_right_hold),
        .move_left_step (move_left_step),
        .move_right_step(move_right_step),
        .paddle_x       (pixel_paddle_x),
        .paddle_y       ()   // unused; Y fixed above
    );

    // =================================================================
    // 4) Collisions
    // =================================================================
    wire collision_left, collision_right, collision_top;
    wire miss_ball;
    wire collision_paddle;
    wire collision_brick_leftright, collision_brick_topbottom;
    wire [6:0] hit_idx;
    wire [76:0] active_bricks;

<<<<<<< HEAD
    collision_detection #(.H_VISIBLE(640), .V_VISIBLE(480),
    .BALL_R(8), .PADDLE_W(80), .BRICK_W(64), .BRICK_H(16)
     ) coll_inst (
    .ball_x           (pixel_ball_x),
    .ball_y           (pixel_ball_y),
    .paddle_x         (pixel_paddle_x),
    .paddle_y         (paddle_y),
=======
    // --- Paddle Y fixed position ---
    wire [9:0] paddle_y = 432;  // near bottom of the screen
>>>>>>> 03d97bf (modified ball_motion and collision_detection to integrate with vga_controller; needs to be tested)

    // no active single-brick wired yet; safe tie-offs
    .brick_x          (10'd0),
    .brick_y          (10'd0),
    .brick_active     (1'b0),

<<<<<<< HEAD
    .collision_left   (collision_left),
    .collision_right  (collision_right),
    .collision_top    (collision_top),
    .collision_paddle (collision_paddle),
    .collision_brick  (collision_brick)
     );
=======
    // --- Instantiate Collision Detection ---
    collision_detection coll_inst (
        .ball_x(ball_x),
        .ball_y(ball_y),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .collision_left(collision_left),
        .collision_right(collision_right),
        .collision_top(collision_top),
        .collision_paddle(collision_paddle),
        .collision_brick_leftright(collision_brick_leftright),
        .collision_brick_topbottom(collision_brick_topbottom),
        .hit_idx(hit_idx),
        .miss_ball(miss_ball)
    );
>>>>>>> 03d97bf (modified ball_motion and collision_detection to integrate with vga_controller; needs to be tested)

    // =================================================================
    // 5) Ball motion (update on frame_tick)
    // =================================================================
    ball_motion ball_inst (
<<<<<<< HEAD
        .clk              (clk_pix),
        .reset            (rst_pix),
        .collision_left   (collision_left),
        .collision_right  (collision_right),
        .collision_top    (collision_top),
        .collision_paddle (collision_paddle),
        .collision_brick  (collision_brick),
        .frame_tick       (frame_tick),   // ensure ball_motion has this port
        .ball_x           (pixel_ball_x),
        .ball_y           (pixel_ball_y)
=======
        .clk(clk),
        .reset(reset),
        .collision_left(collision_left),
        .collision_right(collision_right),
        .collision_top(collision_top),
        .collision_paddle(collision_paddle),
        .collision_brick(collision_brick),
        .collision_brick_leftright(collision_brick_leftright),
        .collision_brick_topbottom(collision_brick_topbottom),
        .miss_ball(miss_ball),
        .ball_x(ball_x),
        .ball_y(ball_y)
>>>>>>> 03d97bf (modified ball_motion and collision_detection to integrate with vga_controller; needs to be tested)
    );

    // =================================================================
    // 6) ScoreKeeper (100 MHz domain) with CDC for HIT
    // =================================================================
    // Resync collision_brick (pixel clk) into 100MHz clk domain
    reg coll_brick_meta, coll_brick_sys, coll_brick_sys_d;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            coll_brick_meta  <= 1'b0;
            coll_brick_sys   <= 1'b0;
            coll_brick_sys_d <= 1'b0;
        end else begin
            coll_brick_meta  <= collision_brick; // from clk_pix domain
            coll_brick_sys   <= coll_brick_meta; // 2-FF sync in clk domain
            coll_brick_sys_d <= coll_brick_sys;
        end
    end
    wire score_hit_pulse = coll_brick_sys & ~coll_brick_sys_d;

    ScoreKeeper score_i (
        .clk100mhz (clk),
        .HIT       (score_hit_pulse),
        .RESET     (reset),     // or hook a dedicated score-reset button
        .SEG       (SEG),
        .AN        (AN),
        .DP        (DP)
    );

endmodule