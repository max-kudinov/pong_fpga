module board_top (
    input  logic                    clk_i,
    input  logic                    rst_n_i,
    input  logic [KEYS_W-1:0]       keys_i,
    output logic [LEDS_W-1:0]       leds_o,
    output logic [VGA_RGB_W-1:0]    vga_rgb_o,
    output logic                    vga_vs_o,
    output logic                    vga_hs_o
);

    logic              rst;
    logic [KEYS_W-1:0] keys;
    logic [LEDS_W-1:0] leds;

    // Basically the whole purpose of this module is to invert signals
    assign rst    = ~rst_n_i;
    assign keys   = ~keys_i;
    assign leds_o = ~leds;

    game_top i_game_top (
        .clk_i     ( clk_i     ),
        .rst_i     ( rst       ),
        .keys_i    ( keys      ),
        .leds_o    ( leds      ),
        .vga_rgb_o ( vga_rgb_o ),
        .vga_hs_o  ( vga_hs_o  ),
        .vga_vs_o  ( vga_vs_o  )
    );

endmodule
