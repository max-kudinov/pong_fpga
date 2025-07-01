`include "board_pkg.svh"
`include "vga_pkg.svh"
`include "sprite_pkg.svh"

module game_top
    import board_pkg::*,
           sprite_pkg::N_SPRITES,
           vga_pkg::X_POS_W,
           vga_pkg::Y_POS_W;
(
    input  logic                    clk_i,
    input  logic                    rst_i,
    input  logic [   KEYS_W-1:0]    keys_i,
    output logic [   LEDS_W-1:0]    leds_o,
    // output logic [VGA_RGB_W-1:0]    vga_rgb_o,
    // output logic                    vga_vs_o,
    // output logic                    vga_hs_o
    input  logic                 serial_clk,
    output logic [          2:0] tmds_data_p,
    output logic [          2:0] tmds_data_n,
    output logic                 tmds_clk_p,
    output logic                 tmds_clk_n
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
        .serial_clk  (serial_clk),
        .tmds_data_p ( tmds_data_p ),
        .tmds_data_n ( tmds_data_n ),
        .tmds_clk_p  ( tmds_clk_p  ),
        .tmds_clk_n  ( tmds_clk_n  ),

        // .vga_hs_o    ( vga_hs_o  ),
        // .vga_vs_o    ( vga_vs_o  ),
        // .vga_rgb_o   ( vga_rgb_o ),
        .new_frame_o ( new_frame ),
        .sprites_i   ( sprites   ),
        .score_i     ( score     )
    );

endmodule
