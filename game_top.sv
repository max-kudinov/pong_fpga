`include "config.svh"

module game_top (
    input  logic                    clk_i,
    input  logic                    rst_i,
    input  logic [`KEYS_W    - 1:0] keys_i,
    output logic [`LEDS_W    - 1:0] leds_o,
    output logic [`VGA_RGB_W - 1:0] vga_rgb_o,
    output logic                    vga_vs_o,
    output logic                    vga_hs_o
);

    logic [`X_POS_W - 1:0] x_pos;
    logic [`Y_POS_W - 1:0] y_pos;
    logic                  visible_range;

    // Player
    logic [`X_POS_W - 1:0] player_paddle_x;
    logic [`Y_POS_W - 1:0] player_paddle_y;

    // Computer
    logic [`X_POS_W - 1:0] pc_paddle_x;
    logic [`Y_POS_W - 1:0] pc_paddle_y;

    // Ball
    logic [`X_POS_W - 1:0] ball_x;
    logic [`Y_POS_W - 1:0] ball_y;

    assign leds_o = keys_i;

    game_logic i_game_logic (
        .clk_i             ( clk_i           ),
        .rst_i             ( rst_i           ),
        .keys_i            ( keys_i          ),
        .player_paddle_x_o ( player_paddle_x ),
        .player_paddle_y_o ( player_paddle_y ),
        .pc_paddle_x_o     ( pc_paddle_x     ),
        .pc_paddle_y_o     ( pc_paddle_y     ),
        .ball_x_o          ( ball_x          ),
        .ball_y_o          ( ball_y          )
    );

    // TODO: move vga to game_display
    vga i_vga (
        .clk_i           ( clk_i         ),
        .rst_i           ( rst_i         ),
        .hsync_o         ( vga_hs_o      ),
        .vsync_o         ( vga_vs_o      ),
        .pixel_x_o       ( x_pos         ),
        .pixel_y_o       ( y_pos         ),
        .visible_range_o ( visible_range )
    );

    game_display i_game_display (
        .clk_i               ( clk_i           ),
        .rst_i               ( rst_i           ),
        .vga_x_pos_i         ( x_pos           ),
        .vga_y_pos_i         ( y_pos           ),
        .player_paddle_x_i   ( player_paddle_x ),
        .player_paddle_y_i   ( player_paddle_y ),
        .pc_paddle_x_i       ( pc_paddle_x     ),
        .pc_paddle_y_i       ( pc_paddle_y     ),
        .ball_x_i            ( ball_x          ),
        .ball_y_i            ( ball_y          ),
        .vga_visible_range_i ( visible_range   ),
        .vga_rgb_o           ( vga_rgb_o       )
    );

endmodule
