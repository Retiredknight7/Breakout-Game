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
    input  wire        clk,         // 100 MHz
    input  wire        reset,       // async, active-high
    input  wire        move_left,
    input  wire        move_right,
    output wire        hsync,
    output wire        vsync,
    output wire [11:0] rgb,
    output wire [6:0]  SEG,
    output wire [7:0]  AN,
    output wire        DP
);

    // ----------------------------------
    // Pixel clock & reset sync
    // ----------------------------------
    wire clk_pix;
    vga_clk clkgen (.clk(clk), .reset(reset), .clk_out(clk_pix));

    reg [1:0] rst_sync;
    always @(posedge clk_pix or posedge reset) begin
        if (reset) rst_sync <= 2'b11;
        else       rst_sync <= {1'b0, rst_sync[1]};
    end
    wire rst_pix = rst_sync[0];

    // ----------------------------------
    // VGA path
    // ----------------------------------
    wire [9:0] paddle_x, paddle_y, ball_x, ball_y;
    wire collision_paddle_raw;

    vga_controller vga (
        .clk(clk_pix),
        .reset(rst_pix),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .bricks(active_bricks),
        .collision_paddle(collision_paddle_raw),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );

    // frame_tick on rising vsync
    reg vsync_d;
    always @(posedge clk_pix or posedge rst_pix) begin
        if (rst_pix) vsync_d <= 1'b0;
        else         vsync_d <= vsync;
    end
    wire frame_tick = vsync & ~vsync_d;

    // ----------------------------------
    // Inputs (debounced)
    // ----------------------------------
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
    wire move_left_step   = left_db  & ~left_d;
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
        .paddle_y       (paddle_y)
    );

    // ----------------------------------
    // Brick Memory & Collision Detection
    // ----------------------------------
    reg  [76:0] active_bricks;
    wire        coll_left, coll_right, coll_top, coll_paddle;
    wire        coll_br_lr, coll_br_tb, miss_ball;
    wire [6:0]  hit_idx_raw;

    collision_detection coll_inst (
        .ball_x(ball_x),
        .ball_y(ball_y),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .active_bricks(active_bricks),
        .collision_left(coll_left),
        .collision_right(coll_right),
        .collision_top(coll_top),
        .collision_paddle(coll_paddle),
        .collision_brick_leftright(coll_br_lr),
        .collision_brick_topbottom(coll_br_tb),
        .hit_idx(hit_idx_raw),
        .miss_ball(miss_ball)
    );

    // ----------------------------------
    // Brick hit latching (once per frame)
    // ----------------------------------
    reg [6:0] hit_idx_frame;
    reg       brick_lr_frame, brick_tb_frame;
    reg       brick_hit_frame;

    always @(posedge clk_pix or posedge rst_pix) begin
        if (rst_pix) begin
            hit_idx_frame   <= 7'd0;
            brick_lr_frame  <= 1'b0;
            brick_tb_frame  <= 1'b0;
            brick_hit_frame <= 1'b0;
        end else if (frame_tick) begin
            brick_hit_frame <= (coll_br_lr | coll_br_tb);
            brick_lr_frame  <= coll_br_lr;
            brick_tb_frame  <= coll_br_tb;
            hit_idx_frame   <= hit_idx_raw;
        end
    end

    // ----------------------------------
    // Remove brick after hit
    // ----------------------------------
    always @(posedge clk_pix or posedge rst_pix) begin
        if (rst_pix) begin
            active_bricks <= {77{1'b1}};
        end else if (frame_tick && brick_hit_frame) begin
            active_bricks[hit_idx_frame] <= 1'b0;
        end
    end

    // ----------------------------------
    // Ball motion
    // ----------------------------------
    ball_motion #(.BALL_SIZE(8)) ball_inst (
        .clk                      (clk_pix),
        .reset                    (rst_pix),
        .frame_tick               (frame_tick),
        .collision_paddle         (coll_paddle),
        .collision_left           (coll_left),
        .collision_right          (coll_right),
        .collision_top            (coll_top),
        .collision_brick_leftright(coll_br_lr),
        .collision_brick_topbottom(coll_br_tb),
        .miss_ball                (miss_ball),
        .paddle_y                 (paddle_y),
        .ball_x                   (ball_x),
        .ball_y                   (ball_y)
    );

    // --------------------------------------------------------
    // COLUMN-BASED SCORING TABLE (now placed in correct spot)
    // --------------------------------------------------------
    localparam [7:0] COLUMN_POINTS_0  = 8'd1;
    localparam [7:0] COLUMN_POINTS_1  = 8'd2;
    localparam [7:0] COLUMN_POINTS_2  = 8'd3;
    localparam [7:0] COLUMN_POINTS_3  = 8'd4;
    localparam [7:0] COLUMN_POINTS_4  = 8'd5;
    localparam [7:0] COLUMN_POINTS_5  = 8'd5;
    localparam [7:0] COLUMN_POINTS_6  = 8'd4;
    localparam [7:0] COLUMN_POINTS_7  = 8'd3;
    localparam [7:0] COLUMN_POINTS_8  = 8'd2;
    localparam [7:0] COLUMN_POINTS_9  = 8'd1;
    localparam [7:0] COLUMN_POINTS_10 = 8'd10;
    
    wire [3:0] hit_col    = hit_idx_frame % 11;
    reg [7:0] score_value;
    always @(*) begin
        case (hit_col)
            4'd0:  score_value = COLUMN_POINTS_0;
            4'd1:  score_value = COLUMN_POINTS_1;
            4'd2:  score_value = COLUMN_POINTS_2;
            4'd3:  score_value = COLUMN_POINTS_3;
            4'd4:  score_value = COLUMN_POINTS_4;
            4'd5:  score_value = COLUMN_POINTS_5;
            4'd6:  score_value = COLUMN_POINTS_6;
            4'd7:  score_value = COLUMN_POINTS_7;
            4'd8:  score_value = COLUMN_POINTS_8;
            4'd9:  score_value = COLUMN_POINTS_9;
            4'd10: score_value = COLUMN_POINTS_10;
            default: score_value = 8'd0;
        endcase
    end

    // ----------------------------------
    // Scoring pulses (pixel -> 100 MHz)
    // ----------------------------------
    wire score_hit_pix_pulse = frame_tick & brick_hit_frame;

    reg hit_meta, hit_sync, hit_sync_d;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            hit_meta   <= 1'b0;
            hit_sync   <= 1'b0;
            hit_sync_d <= 1'b0;
        end else begin
            hit_meta   <= score_hit_pix_pulse;
            hit_sync   <= hit_meta;
            hit_sync_d <= hit_sync;
        end
    end

    wire score_hit_pulse = hit_sync & ~hit_sync_d;

    // ----------------------------------
    // ScoreKeeper (variable POINTS)
    // ----------------------------------
    ScoreKeeper score_i (
        .clk100mhz (clk),
        .HIT       (score_hit_pulse),
        .POINTS    (score_value),
        .RESET     (reset),
        .SEG       (SEG),
        .AN        (AN),
        .DP        (DP)
    );

endmodule

/*module breakout_top( 
    input  wire        clk,         // 100 MHz
    input  wire        reset,       // async, active-high
    input  wire        move_left,
    input  wire        move_right,
    output wire        hsync,
    output wire        vsync,
    output wire [11:0] rgb,
    output wire [6:0]  SEG,
    output wire [7:0]  AN,
    output wire        DP
);
    // ----------------------------------
    // Pixel clock & reset sync
    // ----------------------------------
    wire clk_pix;
    vga_clk clkgen (.clk(clk), .reset(reset), .clk_out(clk_pix));

    reg [1:0] rst_sync;
    always @(posedge clk_pix or posedge reset) begin
        if (reset) rst_sync <= 2'b11;
        else       rst_sync <= {1'b0, rst_sync[1]};
    end
    wire rst_pix = rst_sync[0];

    // ----------------------------------
    // VGA path (your controller wraps vga_sync + pixel_gen)
    // ----------------------------------
    wire [9:0] paddle_x, paddle_y, ball_x, ball_y;
    wire collision_paddle_raw;

    vga_controller vga (
        .clk(clk_pix),
        .reset(rst_pix),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .bricks(active_bricks),
        .collision_paddle(collision_paddle_raw),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );

    // frame_tick: rising edge of vsync (active-low)
    reg vsync_d;
    always @(posedge clk_pix or posedge rst_pix) begin
        if (rst_pix) vsync_d <= 1'b0;
        else         vsync_d <= vsync;
    end
    wire frame_tick = vsync & ~vsync_d;

    // ----------------------------------
    // Inputs (debounced)
    // ----------------------------------
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
    wire move_left_step   = left_db  & ~left_d;
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
        .paddle_y       (paddle_y)
    );

    // ----------------------------------
    // Bricks & collisions
    // ----------------------------------
    reg  [76:0] active_bricks;
    wire        coll_left, coll_right, coll_top, coll_paddle;
    wire        coll_br_lr, coll_br_tb, miss_ball;
    wire [6:0]  hit_idx_raw;

    collision_detection coll_inst (
        .ball_x(ball_x),
        .ball_y(ball_y),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .active_bricks(active_bricks),
        .collision_left(coll_left),
        .collision_right(coll_right),
        .collision_top(coll_top),
        .collision_paddle(coll_paddle),
        .collision_brick_leftright(coll_br_lr),
        .collision_brick_topbottom(coll_br_tb),
        .hit_idx(hit_idx_raw),
        .miss_ball(miss_ball)
    );

    // Latch brick event ONCE per frame (stable index & axis)
    reg [6:0] hit_idx_frame;
    reg       brick_lr_frame, brick_tb_frame;  // which axis to bounce (informative)
    reg       brick_hit_frame;

    always @(posedge clk_pix or posedge rst_pix) begin
        if (rst_pix) begin
            hit_idx_frame   <= 7'd0;
            brick_lr_frame  <= 1'b0;
            brick_tb_frame  <= 1'b0;
            brick_hit_frame <= 1'b0;
        end else if (frame_tick) begin
            brick_hit_frame <= (coll_br_lr | coll_br_tb); // one-shot per frame
            brick_lr_frame  <= coll_br_lr;
            brick_tb_frame  <= coll_br_tb;
            hit_idx_frame   <= hit_idx_raw;
        end
    end

    // Remove exactly one brick per frame if we registered a hit this frame
    always @(posedge clk_pix or posedge rst_pix) begin
      if (rst_pix) begin
        active_bricks <= {77{1'b1}};
      end else if (frame_tick && brick_hit_frame) begin
        active_bricks[hit_idx_frame] <= 1'b0;
      end
    end

    // ----------------------------------
    // Ball motion (uses raw collisions; it samples them on frame_tick internally)
    // ----------------------------------
    ball_motion #(.BALL_SIZE(8)) ball_inst (
        .clk                      (clk_pix),
        .reset                    (rst_pix),
        .frame_tick               (frame_tick),
        .collision_paddle         (coll_paddle),
        .collision_left           (coll_left),
        .collision_right          (coll_right),
        .collision_top            (coll_top),
        .collision_brick_leftright(coll_br_lr),
        .collision_brick_topbottom(coll_br_tb),
        .miss_ball                (miss_ball),
        .paddle_y                 (paddle_y),
        .ball_x                   (ball_x),
        .ball_y                   (ball_y)
    );

    // ----------------------------------
    // Scoring – one pulse per brick removed (frame domain -> 100 MHz domain)
    // ----------------------------------
    // Generate a 1-cycle pulse in the pixel domain on frame_tick when a brick is removed
    wire score_hit_pix_pulse = frame_tick & brick_hit_frame;

    // 2-flop sync into 100 MHz, then edge-detect
    reg hit_meta, hit_sync, hit_sync_d;
    always @(posedge clk or posedge reset) begin
      if (reset) begin
        hit_meta   <= 1'b0;
        hit_sync   <= 1'b0;
        hit_sync_d <= 1'b0;
      end else begin
        hit_meta   <= score_hit_pix_pulse;
        hit_sync   <= hit_meta;
        hit_sync_d <= hit_sync;
      end
    end
    wire score_hit_pulse = hit_sync & ~hit_sync_d;

    // Use your existing ScoreKeeper OR use the simple one below.
    ScoreKeeper score_i (
        .clk100mhz (clk),
        .HIT       (score_hit_pulse),
        .POINTS    (score_value),
        .RESET     (rst_pix),
        .SEG       (SEG),
        .AN        (AN),
        .DP        (DP)
    );
endmodule
*/















/*
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
    wire collision_left_raw, collision_right_raw, collision_top_raw;
    wire collision_paddle_raw, collision_brick_leftright_raw, collision_brick_topbottom_raw;
    wire miss_ball;
    wire [9:0] paddle_x, ball_x, ball_y;
    wire [9:0] paddle_y;
    wire [6:0] hit_idx;

    // Brick bitmap
    reg [76:0] active_bricks;

    // --- Pixel clock ---
    wire clk_pix;
    vga_clk clkgen (
        .clk     (clk),
        .reset   (reset),
        .clk_out (clk_pix)
    );

    // Sync reset to pix clock
    reg [1:0] rst_sync;
    always @(posedge clk_pix or posedge reset) begin
        if (reset) rst_sync <= 2'b11;
        else       rst_sync <= {1'b0, rst_sync[1]};
    end
    wire rst_pix = rst_sync[0];

    // --- VGA Controller ---
    vga_controller vga (
        .clk(clk_pix),
        .reset(rst_pix),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .bricks(active_bricks),
        .collision_paddle(collision_paddle_raw),  // raw to pixel_gen for debug
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );
    
    // frame_tick: 1 pulse per frame
    reg vsync_d;
    always @(posedge clk_pix or posedge rst_pix) begin
        if (rst_pix) vsync_d <= 1'b0;
        else         vsync_d <= vsync;
    end
    wire frame_tick = vsync & ~vsync_d;

    // --- Paddle control ---

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
    wire move_left_step   = left_db  & ~left_d;
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
        .paddle_y       (paddle_y)
    );

    // --- Collision Detection (raw) ---

    collision_detection coll_inst (
        .ball_x(ball_x),
        .ball_y(ball_y),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .active_bricks(active_bricks),
        .collision_left(collision_left_raw),
        .collision_right(collision_right_raw),
        .collision_top(collision_top_raw),
        .collision_paddle(collision_paddle_raw),
        .collision_brick_leftright(collision_brick_leftright_raw),
        .collision_brick_topbottom(collision_brick_topbottom_raw),
        .hit_idx(hit_idx),
        .miss_ball(miss_ball)
    );

    // --- Brick grid update ---

    always @(posedge clk_pix or posedge rst_pix) begin
      if (rst_pix) begin
        active_bricks <= {77{1'b1}};
      end else begin
        if (brick_hit_pix_pulse)
          active_bricks[hit_idx] <= 1'b0;
      end
    end

    // --- Ball Motion uses RAW collisions directly ---

    ball_motion ball_inst (
        .clk                    (clk_pix),
        .reset                  (rst_pix),
        .frame_tick             (frame_tick),
        .collision_paddle       (collision_paddle_raw),
        .collision_left         (collision_left_raw),
        .collision_right        (collision_right_raw),
        .collision_top          (collision_top_raw),
        .collision_brick_leftright (collision_brick_leftright_raw),
        .collision_brick_topbottom (collision_brick_topbottom_raw),
        .miss_ball              (miss_ball),
        .ball_x                 (ball_x),
        .ball_y                 (ball_y)
    );

    // --- ScoreKeeper sync (same as before) ---

    wire brick_hit_raw = collision_brick_leftright_raw | collision_brick_topbottom_raw;
    
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
        hit_meta   <= brick_hit_pix_pulse;
        hit_sync   <= hit_meta;
        hit_sync_d <= hit_sync;
      end
    end
    
    wire score_hit_pulse = hit_sync & ~hit_sync_d; 
    
    ScoreKeeper score_i (
        .clk100mhz (clk),
        .HIT       (score_hit_pulse),
        .RESET     (rst_pix),
        .SEG       (SEG),
        .AN        (AN),
        .DP        (DP)
    );

endmodule
*/
