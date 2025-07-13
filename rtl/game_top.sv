`include "board_pkg.svh"
`include "sprite_pkg.svh"

module game_top
    import board_pkg::*,
           sprite_pkg::N_SPRITES;
(
    input  logic                    clk_i,
    input  logic                    rst_i,
    input  logic [   KEYS_W-1:0]    keys_i,
    output logic [   LEDS_W-1:0]    leds_o,

    display_if display
);
    logic     new_frame;

    sprite_if sprites [N_SPRITES] ();
    score_if  score               ();

    game_logic i_game_logic (
        .clk_i       ( clk_i     ),
        .rst_i       ( rst_i     ),
        .keys_i      ( keys_i    ),
        .new_frame_i ( new_frame ),
        .leds_o      ( leds_o    ),
        .sprites_o   ( sprites   ),
        .score_o     ( score     )
    );

    game_display i_game_display (
        .clk_i       ( clk_i     ),
        .rst_i       ( rst_i     ),

        .new_frame_o ( new_frame ),
        .sprites_i   ( sprites   ),
        .score_i     ( score     ),

        .display     ( display   )
    );

endmodule
