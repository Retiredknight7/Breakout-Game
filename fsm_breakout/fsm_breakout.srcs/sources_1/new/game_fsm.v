`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025
// Design Name: Game FSM
// Module Name: game_fsm
// Project Name: Breakout Game
// Target Devices: Nexys A7-100T
// Tool Versions: Vivado
// Description: Mealy FSM for controlling game states and transitions
//////////////////////////////////////////////////////////////////////////////////

module game_fsm(
    input clk,
    input reset,
    input start,
    input hit_brick,
    input hit_wall,
    input miss_ball,
    input [3:0] lives,
    input bricks_left,
    output reg display_start,
    output reg display_win,
    output reg display_gameover,
    output reg reflect_ball,
    output reg reset_ball,
    output reg score_enable,
    output reg game_active
);

    // State encoding
    parameter IDLE       = 3'b000;
    parameter PLAY       = 3'b001;
    parameter HIT_BRICK  = 3'b010;
    parameter HIT_WALL   = 3'b011;
    parameter MISS_BALL  = 3'b100;
    parameter WIN        = 3'b101;
    parameter GAME_OVER  = 3'b110;

    reg [2:0] current_state, next_state;

    // Sequential logic: state update
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        case (current_state)
            IDLE: 
                next_state = start ? PLAY : IDLE;

            PLAY: 
                if (hit_brick)
                    next_state = HIT_BRICK;
                else if (hit_wall)
                    next_state = HIT_WALL;
                else if (miss_ball)
                    next_state = MISS_BALL;
                else if (!bricks_left)
                    next_state = WIN;
                else
                    next_state = PLAY;

            HIT_BRICK: next_state = PLAY;
            HIT_WALL:  next_state = PLAY;
            MISS_BALL: next_state = (lives == 0) ? GAME_OVER : PLAY;
            WIN:       next_state = IDLE;
            GAME_OVER: next_state = IDLE;

            default:   next_state = IDLE;
        endcase
    end

    // Output logic (Mealy FSM)
    always @(*) begin
        // Default outputs
        display_start = 0;
        display_win = 0;
        display_gameover = 0;
        reflect_ball = 0;
        reset_ball = 0;
        score_enable = 0;
        game_active = 0;

        case (current_state)
            IDLE: display_start = 1;

            PLAY: game_active = 1;

            HIT_BRICK: begin
                reflect_ball = 1;
                score_enable = 1;
            end

            HIT_WALL: reflect_ball = 1;

            MISS_BALL: reset_ball = 1;

            WIN: display_win = 1;

            GAME_OVER: display_gameover = 1;
        endcase
    end

endmodule
