`include "score_pkg.svh"

module game_score_decoder
    import score_pkg::*;
(
    input  logic                   clk_i,
    input  logic                   rst_i,
    input  logic [MAX_SCORE_W-1:0] player_score_i,
    input  logic [MAX_SCORE_W-1:0] enemy_score_i,

    output score_t                 player_score_dec_o,
    output score_t                 enemy_score_dec_o
);

    score_t player_score_dec_next;
    score_t enemy_score_dec_next;

    always_comb begin
        case (player_score_i)
            MAX_SCORE_W'(0): player_score_dec_next = ZERO;
            MAX_SCORE_W'(1): player_score_dec_next = ONE;
            MAX_SCORE_W'(2): player_score_dec_next = TWO;
            MAX_SCORE_W'(3): player_score_dec_next = THREE;
            MAX_SCORE_W'(4): player_score_dec_next = FOUR;
            MAX_SCORE_W'(5): player_score_dec_next = FIVE;
            MAX_SCORE_W'(6): player_score_dec_next = SIX;
            MAX_SCORE_W'(7): player_score_dec_next = SEVEN;
            MAX_SCORE_W'(8): player_score_dec_next = EIGHT;
            MAX_SCORE_W'(9): player_score_dec_next = NEIN;
            default: begin
                player_score_dec_next = ZERO;
                `ifdef SIMULATION
                    $error("Invalid player_score_dec_next value: %0d",
                             player_score_dec_next);
                    $finish;
                `endif
            end

        endcase

        case (enemy_score_i)
            MAX_SCORE_W'(0): enemy_score_dec_next = ZERO;
            MAX_SCORE_W'(1): enemy_score_dec_next = ONE;
            MAX_SCORE_W'(2): enemy_score_dec_next = TWO;
            MAX_SCORE_W'(3): enemy_score_dec_next = THREE;
            MAX_SCORE_W'(4): enemy_score_dec_next = FOUR;
            MAX_SCORE_W'(5): enemy_score_dec_next = FIVE;
            MAX_SCORE_W'(6): enemy_score_dec_next = SIX;
            MAX_SCORE_W'(7): enemy_score_dec_next = SEVEN;
            MAX_SCORE_W'(8): enemy_score_dec_next = EIGHT;
            MAX_SCORE_W'(9): enemy_score_dec_next = NEIN;
            default: begin
                enemy_score_dec_next = ZERO;
                `ifdef SIMULATION
                    $error("Invalid enemy_score_dec_next value: %0d",
                             enemy_score_dec_next);
                    $finish;
                `endif
            end
        endcase
    end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            player_score_dec_o <= ZERO;
            enemy_score_dec_o  <= ZERO;
        end else begin
            player_score_dec_o <= player_score_dec_next;
            enemy_score_dec_o  <= enemy_score_dec_next;
        end

endmodule
