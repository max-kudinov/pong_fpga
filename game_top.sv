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
    output logic [VGA_RGB_W-1:0]    vga_rgb_o,
    output logic                    vga_vs_o,
    output logic                    vga_hs_o
);
    logic     new_frame;

    sprite_if sprites [N_SPRITES] ();

    game_logic i_game_logic (
        .clk_i       ( clk_i     ),
        .rst_i       ( rst_i     ),
        .keys_i      ( keys_i    ),
        .new_frame_i ( new_frame ),
        .leds_o      ( leds_o    ),
        .sprites_o   ( sprites   )
    );

    game_display i_game_display (
        .clk_i       ( clk_i     ),
        .rst_i       ( rst_i     ),
        .vga_hs_o    ( vga_hs_o  ),
        .vga_vs_o    ( vga_vs_o  ),
        .vga_rgb_o   ( vga_rgb_o ),
        .new_frame_o ( new_frame ),
        .sprites_i   ( sprites   )
    );

endmodule
