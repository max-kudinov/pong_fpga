module board_top
# (
    parameter CLK_MHZ = 50,
    parameter H_RES   = 640,
    parameter V_RES   = 480
)
(
    input  logic       clk_i,
    input  logic       rst_n_i,
    input  logic [1:0] keys_i,
    output logic [2:0] vga_rgb_o,
    output logic       vga_vs_o,
    output logic       vga_hs_o
);
    logic rst;

    // Basically the whole purpose of this module is to invert reset
    assign rst = ~rst_n_i;

    game_top
    # (
        .CLK_MHZ ( CLK_MHZ ),
        .H_RES   ( H_RES   ),
        .V_RES   ( V_RES   )
    )
    i_game_top
    (
        .clk_i     ( clk_i     ),
        .rst_i     ( rst       ),
        .keys_i    ( keys_i     ),
        .vga_rgb_o ( vga_rgb_o ),
        .vga_hs_o  ( vga_hs_o  ),
        .vga_vs_o  ( vga_vs_o  )
    );

endmodule
