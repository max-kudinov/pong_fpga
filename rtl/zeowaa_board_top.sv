`include "board_pkg.svh"
`include "display_pkg.svh"

`ifdef ZEOWAA

module zeowaa_board_top
    import board_pkg::*,
           display_pkg::RGB_W;
(
    input  logic              clk_i,
    input  logic              rst_n_i,
    input  logic [KEYS_W-1:0] keys_i,
    output logic [LEDS_W-1:0] leds_o,
    output logic [ RGB_W-1:0] vga_rgb_o,
    output logic              vga_vs_o,
    output logic              vga_hs_o
);

    display_if display ();

    logic              rst;
    logic              upload_rst_n;
    logic [KEYS_W-1:0] keys;
    logic [LEDS_W-1:0] leds;

    // Reset on upload
    initial begin
        upload_rst_n = '0;
    end

    always_ff @(posedge clk_i)
        upload_rst_n <= '1;

    // Ivert board signals
    assign rst    = ~rst_n_i || ~upload_rst_n;
    assign keys   = ~keys_i;
    assign leds_o = ~leds;

    // Unwrap interface signals
    assign vga_rgb_o = display.vga_rgb;
    assign vga_vs_o  = display.vga_vs;
    assign vga_hs_o  = display.vga_hs;

    game_top i_game_top (
        .clk_i     ( clk_i   ),
        .rst_i     ( rst     ),
        .keys_i    ( keys    ),
        .leds_o    ( leds    ),
        .display   ( display )
    );

endmodule

`endif
