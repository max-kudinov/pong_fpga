`include "score_pkg.svh"

module game_score
    import score_pkg::*;
(
    input  logic                 clk_i,
    input  logic                 rst_i,
    input  logic [M_SCORE_W-1:0] player_score_i,
    input  logic [M_SCORE_W-1:0] enemy_score_i,

    score_if.control_mp          score_o
);

    score_t player_s;
    score_t enemy_s;

    // Set score coordinates
    assign player_s.x_pos = PS_X;
    assign player_s.y_pos = PS_Y;
    assign enemy_s.x_pos = ES_X;
    assign enemy_s.y_pos = ES_Y;

    always_comb begin
        case (player_score_i)
            M_SCORE_W'(0): player_s.score_val = score0;
            M_SCORE_W'(1): player_s.score_val = score1;
            M_SCORE_W'(2): player_s.score_val = score2;
            M_SCORE_W'(3): player_s.score_val = score3;
            M_SCORE_W'(4): player_s.score_val = score4;
            M_SCORE_W'(5): player_s.score_val = score5;
            M_SCORE_W'(6): player_s.score_val = score6;
            M_SCORE_W'(7): player_s.score_val = score7;
            M_SCORE_W'(8): player_s.score_val = score8;
            M_SCORE_W'(9): player_s.score_val = score9;
            default: player_s.score_val = 'x;
        endcase

        case (enemy_score_i)
            M_SCORE_W'(0): enemy_s.score_val = score0;
            M_SCORE_W'(1): enemy_s.score_val = score1;
            M_SCORE_W'(2): enemy_s.score_val = score2;
            M_SCORE_W'(3): enemy_s.score_val = score3;
            M_SCORE_W'(4): enemy_s.score_val = score4;
            M_SCORE_W'(5): enemy_s.score_val = score5;
            M_SCORE_W'(6): enemy_s.score_val = score6;
            M_SCORE_W'(7): enemy_s.score_val = score7;
            M_SCORE_W'(8): enemy_s.score_val = score8;
            M_SCORE_W'(9): enemy_s.score_val = score9;
            default: enemy_s.score_val = 'x;
        endcase
    end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            score_o.player <= '0;
            score_o.enemy  <= '0;
        end else begin
            score_o.player <= player_s;
            score_o.enemy  <= enemy_s;
        end

endmodule
