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

    // Player
    logic [`X_POS_W - 1:0] player_paddle_x;
    logic [`Y_POS_W - 1:0] player_paddle_y;

    // Computer
    logic [`X_POS_W - 1:0] pc_paddle_x;
    logic [`Y_POS_W - 1:0] pc_paddle_y;

    // Ball
    logic [`X_POS_W - 1:0] ball_x;
    logic [`Y_POS_W - 1:0] ball_y;

    logic                  new_frame;

    assign leds_o = keys_i;

    game_logic i_game_logic (
        .clk_i             ( clk_i           ),
        .rst_i             ( rst_i           ),
        .keys_i            ( keys_i          ),
        .new_frame_i       ( new_frame       ),
        .player_paddle_x_o ( player_paddle_x ),
        .player_paddle_y_o ( player_paddle_y ),
        .pc_paddle_x_o     ( pc_paddle_x     ),
        .pc_paddle_y_o     ( pc_paddle_y     ),
        .ball_x_o          ( ball_x          ),
        .ball_y_o          ( ball_y          )
    );

    game_display i_game_display (
        .clk_i               ( clk_i           ),
        .rst_i               ( rst_i           ),
        .player_paddle_x_i   ( player_paddle_x ),
        .player_paddle_y_i   ( player_paddle_y ),
        .pc_paddle_x_i       ( pc_paddle_x     ),
        .pc_paddle_y_i       ( pc_paddle_y     ),
        .ball_x_i            ( ball_x          ),
        .ball_y_i            ( ball_y          ),
        .vga_hs_o            ( vga_hs_o        ),
        .vga_vs_o            ( vga_vs_o        ),
        .vga_rgb_o           ( vga_rgb_o       ),
        .new_frame_o         ( new_frame       )
    );

endmodule
