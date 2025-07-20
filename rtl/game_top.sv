`include "board_pkg.svh"
`include "sprite_pkg.svh"
`include "score_pkg.svh"

module game_top
    import board_pkg::*,
           sprite_pkg::N_SPRITES,
           score_pkg::score_t;
(
    input  logic                    clk_i,
    input  logic                    rst_i,
    input  logic [   KEYS_W-1:0]    keys_i,
    output logic [   LEDS_W-1:0]    leds_o,

    display_if display
);

    logic     new_frame;

    sprite_if sprites [N_SPRITES] ();

    score_t player_score;
    score_t enemy_score;

    game_logic i_game_logic (
        .clk_i          ( clk_i        ),
        .rst_i          ( rst_i        ),
        .keys_i         ( keys_i       ),
        .new_frame_i    ( new_frame    ),
        .leds_o         ( leds_o       ),
        .player_score_o ( player_score ),
        .enemy_score_o  ( enemy_score  ),
        .sprites_o      ( sprites      )
    );

    game_display i_game_display (
        .clk_i          ( clk_i        ),
        .rst_i          ( rst_i        ),
        .player_score_i ( player_score ),
        .enemy_score_i  ( enemy_score  ),
        .new_frame_o    ( new_frame    ),
        .sprites_i      ( sprites      ),
        .display        ( display      )
    );

endmodule
