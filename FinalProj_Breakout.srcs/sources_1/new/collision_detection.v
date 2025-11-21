`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Paris Talebi & Yshi Blanco
// Module Name: collision_detection
// Description: Detects collisions between the ball, paddle, and bricks,
//              and signals when the ball is missed (goes beyond paddle)
//////////////////////////////////////////////////////////////////////////////////
module collision_detection(
    input [9:0] ball_x,
    input [9:0] ball_y,
    input [9:0] paddle_x,
    input [9:0] paddle_y,
    input [76:0] active_bricks,
    output collision_left,
    output collision_right,
    output collision_top,
    output collision_paddle,
    output collision_brick_leftright,
    output collision_brick_topbottom,
    output [6:0] hit_idx,
    output miss_ball
);

    // Constants
    // Active screen
    localparam ACTIVE_HOR = 640;
    localparam ACTIVE_VERT = 480;
    localparam BORDER_THICKNESS = 4;
    // Paddle
    localparam PADDLE_WIDTH = 8;
    localparam PADDLE_LENGTH = 64;
    // Ball
    localparam BALL_SIZE = 8;
    // Brick
    localparam BRICK_WIDTH = 10;
    localparam BRICK_LENGTH = 53;
    localparam BRICK_GAP = 2;
    localparam BRICK_WIDTH_T = BRICK_WIDTH + BRICK_GAP;
    localparam BRICK_LENGTH_T = BRICK_LENGTH + BRICK_GAP;
    localparam BRICK_ORIGIN_X = 16;
    localparam BRICK_ORIGIN_Y = 48;
    localparam BRICK_ROW = 7;
    localparam BRICK_COL = 11;

    // --- Paddle collision detection ---
    // Ball hits paddle if it's just above paddle_y and within paddle length
    assign collision_paddle = ((ball_y + BALL_SIZE) >= paddle_y) &&
                              ((ball_x + BALL_SIZE) >= paddle_x) &&
                              (ball_x <= (paddle_x + PADDLE_LENGTH));

    // --- Brick collision detection ---
    integer row, col, idx;
    reg lr_hit, tb_hit, found;
    reg [6:0] idx_reg;
    integer top_left, top_right, bottom_left, bottom_right;
    integer left, right, top, bottom;
    
    always @(*) begin
        lr_hit = 0;
        tb_hit = 0;
        found = 0;
        idx_reg = 0;
    
        for (row = 0; row < BRICK_ROW; row = row + 1) begin
            for (col = 0; col < BRICK_COL; col = col + 1) begin
                idx = row * BRICK_COL + col;
                
                // Check if brick should be visible
                if (!found && active_bricks[idx]) begin
                    // Make sure coordinate is within a brick
                    if ((ball_x + BALL_SIZE >= BRICK_ORIGIN_X + col*BRICK_LENGTH_T) && (ball_x < BRICK_ORIGIN_X + col*BRICK_LENGTH_T + BRICK_LENGTH)
                        && (ball_y + BALL_SIZE >= BRICK_ORIGIN_Y + row*BRICK_WIDTH_T) && (ball_y < BRICK_ORIGIN_Y + row*BRICK_WIDTH_T + BRICK_WIDTH)) begin
                        
                        // Check if a corner of the ball is within/touching the brick
                        top_left = ((ball_x >= BRICK_ORIGIN_X + col*BRICK_LENGTH_T) && (ball_x < BRICK_ORIGIN_X + col*BRICK_LENGTH_T + BRICK_LENGTH)
                                    && (ball_y >= BRICK_ORIGIN_Y + row*BRICK_WIDTH_T) && (ball_y < BRICK_ORIGIN_Y + row*BRICK_WIDTH_T + BRICK_WIDTH));
                        top_right = ((ball_x + BALL_SIZE >= BRICK_ORIGIN_X + col*BRICK_LENGTH_T) && (ball_x + BALL_SIZE < BRICK_ORIGIN_X + col*BRICK_LENGTH_T + BRICK_LENGTH)
                                    && (ball_y >= BRICK_ORIGIN_Y + row*BRICK_WIDTH_T) && (ball_y < BRICK_ORIGIN_Y + row*BRICK_WIDTH_T + BRICK_WIDTH));
                        bottom_left = ((ball_x >= BRICK_ORIGIN_X + col*BRICK_LENGTH_T) && (ball_x < BRICK_ORIGIN_X + col*BRICK_LENGTH_T + BRICK_LENGTH)
                                    && (ball_y + BALL_SIZE >= BRICK_ORIGIN_Y + row*BRICK_WIDTH_T) && (ball_y + BALL_SIZE < BRICK_ORIGIN_Y + row*BRICK_WIDTH_T + BRICK_WIDTH));
                        bottom_right = ((ball_x + BALL_SIZE >= BRICK_ORIGIN_X + col*BRICK_LENGTH_T) && (ball_x + BALL_SIZE < BRICK_ORIGIN_X + col*BRICK_LENGTH_T + BRICK_LENGTH)
                                    && (ball_y + BALL_SIZE >= BRICK_ORIGIN_Y + row*BRICK_WIDTH_T) && (ball_y + BALL_SIZE < BRICK_ORIGIN_Y + row*BRICK_WIDTH_T + BRICK_WIDTH));
                        
                        left = top_left + bottom_left;
                        right = top_right + bottom_right;
                        top = top_left + top_right;
                        bottom = bottom_left + bottom_right;
                        
                        if (left != right) begin
                            lr_hit = 1;
                            tb_hit = 0;
                        end else if (bottom_left != bottom_right) begin
                            lr_hit = 0;
                            tb_hit = 1;
                        end else begin
                            lr_hit = 0;
                            tb_hit = 0;
                        end
                        // Output which brick just got hit
                        idx_reg = idx;
                        found = 1;
                    end
                end
            end
        end
    end
    
    assign collision_brick_leftright = lr_hit;
    assign collision_brick_topbottom = tb_hit;
    assign hit_idx = idx_reg;
        
    // --- Ball collision detection ---
    assign collision_left = (ball_x <= BORDER_THICKNESS);
    assign collision_right = ((ball_x + BALL_SIZE) >= (ACTIVE_HOR - BORDER_THICKNESS));
    assign collision_top = (ball_y <= BORDER_THICKNESS);

    // --- Miss ball detection ---
    // If ball goes below the paddle (off-screen)
    assign miss_ball = ((ball_y + BALL_SIZE) >= (ACTIVE_VERT - BORDER_THICKNESS));

endmodule
