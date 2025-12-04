`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Paris Talebi & Yshi Blanco
// Module Name: collision_detection
// Description: Detects collisions between the ball, paddle, and bricks,
//              and signals when the ball is missed (goes beyond paddle)
//////////////////////////////////////////////////////////////////////////////////

module collision_detection(
    input  [9:0] ball_x,
    input  [9:0] ball_y,
    input  [9:0] paddle_x,
    input  [9:0] paddle_y,
    input  [76:0] active_bricks,

    output        collision_left,
    output        collision_right,
    output        collision_top,
    output        collision_paddle,
    output        collision_brick_leftright,
    output        collision_brick_topbottom,
    output [6:0]  hit_idx,
    output        miss_ball
);
    // Screen / objects
    localparam ACTIVE_HOR      = 640;
    localparam ACTIVE_VERT     = 480;
    localparam BORDER_THICKNESS= 4;

    localparam PADDLE_WIDTH    = 8;
    localparam PADDLE_LENGTH   = 64;

    localparam BALL_SIZE       = 8;

    localparam BRICK_WIDTH     = 10;  // height
    localparam BRICK_LENGTH    = 53;  // width
    localparam BRICK_GAP       = 2;
    localparam BRICK_WIDTH_T   = BRICK_WIDTH  + BRICK_GAP;  // pitch Y
    localparam BRICK_LENGTH_T  = BRICK_LENGTH + BRICK_GAP;  // pitch X
    localparam BRICK_ORIGIN_X  = 16;
    localparam BRICK_ORIGIN_Y  = 48;
    localparam BRICK_ROW       = 7;
    localparam BRICK_COL       = 11;

    // Paddle AABB overlap
    assign collision_paddle =
         ((ball_x + BALL_SIZE) >= paddle_x) &&
         ( ball_x               <  (paddle_x + PADDLE_LENGTH)) &&
         ((ball_y + BALL_SIZE) >= paddle_y) &&
         ( ball_y               <  (paddle_y + PADDLE_WIDTH));

    // Ball bounds (wires)
    wire [9:0] x0 = ball_x;
    wire [9:0] y0 = ball_y;
    wire [9:0] x1 = ball_x + BALL_SIZE;
    wire [9:0] y1 = ball_y + BALL_SIZE;

    integer row, col, idx;
    reg     lr_hit, tb_hit, found;
    reg [6:0] idx_reg;

    integer bx0, bx1, by0, by1;  // brick bounds
    integer ix0, ix1, iy0, iy1;  // intersection bounds
    integer int_w, int_h;        // intersection size

    always @* begin
        lr_hit = 1'b0;
        tb_hit = 1'b0;
        found  = 1'b0;
        idx_reg= 7'd0;

        for (row = 0; row < BRICK_ROW; row = row + 1) begin
            for (col = 0; col < BRICK_COL; col = col + 1) begin
                idx = row * BRICK_COL + col;

                if (!found && active_bricks[idx]) begin
                    // Brick bounds
                    bx0 = BRICK_ORIGIN_X + col*BRICK_LENGTH_T;
                    bx1 = bx0 + BRICK_LENGTH;
                    by0 = BRICK_ORIGIN_Y + row*BRICK_WIDTH_T;
                    by1 = by0 + BRICK_WIDTH;

                    // AABB overlap?
                    if ((x1 > bx0) && (x0 < bx1) &&
                        (y1 > by0) && (y0 < by1)) begin

                        // Intersection rectangle
                        ix0 = (x0 > bx0) ? x0 : bx0;
                        ix1 = (x1 < bx1) ? x1 : bx1;
                        iy0 = (y0 > by0) ? y0 : by0;
                        iy1 = (y1 < by1) ? y1 : by1;

                        int_w = ix1 - ix0;
                        int_h = iy1 - iy0;

                        // Axis-of-minimum-penetration (tie -> TB)
                        if (int_w < int_h) begin
                            lr_hit = 1'b1; tb_hit = 1'b0;
                        end else begin
                            lr_hit = 1'b0; tb_hit = 1'b1;
                        end

                        idx_reg = idx[6:0];
                        found   = 1'b1;
                    end
                end
            end
        end
    end

    assign collision_brick_leftright = lr_hit;
    assign collision_brick_topbottom = tb_hit;
    assign hit_idx                   = idx_reg;

    // Walls / top / bottom-miss
    assign collision_left  = (ball_x <= BORDER_THICKNESS);
    assign collision_right = ((ball_x + BALL_SIZE) >= (ACTIVE_HOR  - BORDER_THICKNESS));
    assign collision_top   = (ball_y <= BORDER_THICKNESS);
    assign miss_ball       = ((ball_y + BALL_SIZE) >= (ACTIVE_VERT - BORDER_THICKNESS));
endmodule
