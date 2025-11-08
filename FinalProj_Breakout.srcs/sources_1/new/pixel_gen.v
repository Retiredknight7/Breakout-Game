`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CSULB
// Engineer: Yshi Blanco
// Create Date: 10/22/2025 02:08:44 PM
// Design Name: VGA Controller
// Module Name: pixel_gen
// Project Name: Breakout
// Description: Determines how each pixel will be displayed
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module pixel_gen(
    input wire video_on,
    input wire [9:0] pixel_x, pixel_y,
    input wire [9:0] paddle_x, paddle_y, ball_x, ball_y,
    input wire [76:0] bricks,            // map of 77 bricks
    output reg [11:0] rgb
    );
    
    reg drawBorder, drawPaddle, drawBall, drawBrick;
    
    // Constants
    // Active screen
    localparam ACTIVE_HOR = 640;
    localparam ACTIVE_VERT = 480;
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
    
    integer row, col, idx;
    
    // draw logic
    always @(*) begin
        drawBorder = (pixel_x[9:2] == 0) || (pixel_x[9:2] == ACTIVE_HOR/4-1) 
                    || (pixel_y[8:2] == 0) || (pixel_y[8:2] == ACTIVE_VERT/4-1);
        
        drawPaddle = ((pixel_x >= paddle_x) && (pixel_x < (paddle_x + PADDLE_LENGTH))
                    && (pixel_y >= paddle_y) && (pixel_y < (paddle_y + PADDLE_WIDTH)));
        
        drawBall = ((pixel_x >= ball_x) && (pixel_x < (ball_x + BALL_SIZE))
                   && (pixel_y >= ball_y) && (pixel_y < (ball_y + BALL_SIZE)));
                   
        // Bricks
        // Default to not draw
        drawBrick = 0;
        
        for (row = 0; row < BRICK_ROW; row = row + 1) begin
            for (col = 0; col < BRICK_COL; col = col + 1) begin
                idx = row * BRICK_COL + col;
                
                // Check if brick should be visible
                if (bricks[idx] == 1) begin
                    // Make sure coordinate is not a gap
                    if ((pixel_x >= BRICK_ORIGIN_X + col*BRICK_LENGTH_T) && (pixel_x < BRICK_ORIGIN_X + col*BRICK_LENGTH_T + BRICK_LENGTH)
                        && (pixel_y >= BRICK_ORIGIN_Y + row*BRICK_WIDTH_T) && (pixel_y < BRICK_ORIGIN_Y + row*BRICK_WIDTH_T + BRICK_WIDTH)) begin
                        drawBrick = 1;
                    end
                end
            end
        end
    end
    
    // RGB multiplexer
    always @(*) begin
        if (video_on) begin
            if (drawBorder == 1) begin
                rgb = 12'h00F;
            end else if ((drawBrick | drawBall | drawPaddle) == 1) begin
                rgb = 12'hFFF;
            end else begin
                rgb = 12'h000;
            end
        end else begin
            rgb = 12'h000;
        end
    end
    
endmodule
