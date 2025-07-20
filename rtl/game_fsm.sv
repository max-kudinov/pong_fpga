`include "score_pkg.svh"
`include "board_pkg.svh"

module game_fsm
    import score_pkg::*,
           board_pkg::KEYS_W;
(
    input  logic                   clk_i,
    input  logic                   rst_i,
    input  logic                   game_rst_i,
    input  logic [MAX_SCORE_W-1:0] p_score_i,
    input  logic [MAX_SCORE_W-1:0] e_score_i,
    output logic                   game_en_o
);

    state_e state, next;

    always_ff @(posedge clk_i)
         if (rst_i)
             state <= ST_WAIT_START;
         else
             state <= next;

    always_comb begin
        next = state;

        case (state)
            ST_WAIT_START: begin
                if (game_rst_i) next = ST_PLAY;
            end
            ST_PLAY: begin
                if (p_score_i == MAX_SCORE || e_score_i == MAX_SCORE)
                    next = ST_WAIT_START;
            end
        endcase
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            game_en_o <= '0;
        else
            game_en_o <= (state == ST_PLAY);

endmodule
