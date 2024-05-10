`include "board_pkg.svh"
`include "vga_pkg.svh"
`include "sprite_pkg.svh"

module game_display
    import board_pkg::VGA_RGB_W;
    import vga_pkg::X_POS_W;
    import vga_pkg::Y_POS_W;
    import vga_pkg::SCREEN_H_RES;
    import sprite_pkg::PADDLE_WIDTH;
    import sprite_pkg::PADDLE_HEIGHT;
    import sprite_pkg::BALL_SIDE;
    import sprite_pkg::SEPARATOR_WIDTH;
    import sprite_pkg::SEPARATOR_DOT_HEIGHT;
(
    input  logic                    clk_i,
    input  logic                    rst_i,

    input  logic [X_POS_W - 1:0]   player_paddle_x_i,
    input  logic [Y_POS_W - 1:0]   player_paddle_y_i,

    input  logic [X_POS_W - 1:0]   pc_paddle_x_i,
    input  logic [Y_POS_W - 1:0]   pc_paddle_y_i,

    input  logic [X_POS_W - 1:0]   ball_x_i,
    input  logic [Y_POS_W - 1:0]   ball_y_i,

    output logic                    vga_hs_o,
    output logic                    vga_vs_o,
    output logic [VGA_RGB_W - 1:0]  vga_rgb_o,
    output logic                    new_frame_o
);
    logic [X_POS_W - 1:0]   player_paddle_x;
    logic [Y_POS_W - 1:0]   player_paddle_y;

    logic [X_POS_W - 1:0]   pc_paddle_x;
    logic [Y_POS_W - 1:0]   pc_paddle_y;

    logic [X_POS_W - 1:0]   ball_x;
    logic [Y_POS_W - 1:0]   ball_y;

    logic [VGA_RGB_W - 1:0] vga_rgb_w;
    logic [VGA_RGB_W - 1:0] player_paddle_rgb;
    logic [VGA_RGB_W - 1:0] pc_paddle_rgb;
    logic [VGA_RGB_W - 1:0] ball_rgb;

    logic [X_POS_W - 1:0]   vga_x_pos;
    logic [Y_POS_W - 1:0]   vga_y_pos;
    logic                    vga_visible_range;
    logic                    vga_vs_prev;

    logic                    on_player_paddle;
    logic                    on_pc_paddle;
    logic                    on_ball;

    vga i_vga (
        .clk_i           ( clk_i             ),
        .rst_i           ( rst_i             ),
        .hsync_o         ( vga_hs_o          ),
        .vsync_o         ( vga_vs_o          ),
        .pixel_x_o       ( vga_x_pos         ),
        .pixel_y_o       ( vga_y_pos         ),
        .visible_range_o ( vga_visible_range )
    );

    // Display player paddle
    sprite_display #(
        .RECT_W    ( PADDLE_WIDTH  ),
        .RECT_H    ( PADDLE_HEIGHT )
    ) i_player (
        .clk_i       ( clk_i             ),
        .rst_i       ( rst_i             ),
        .rect_x      ( player_paddle_x   ),
        .rect_y      ( player_paddle_y   ),
        .pixel_x     ( vga_x_pos         ),
        .pixel_y     ( vga_y_pos         ),
        .on_sprite_o ( on_player_paddle  ),
        .vga_rgb_o   ( player_paddle_rgb )
    );

    // Display computer paddle
    sprite_display #(
        .RECT_W    ( PADDLE_WIDTH  ),
        .RECT_H    ( PADDLE_HEIGHT )
    ) i_computer (
        .clk_i       ( clk_i         ),
        .rst_i       ( rst_i         ),
        .rect_x      ( pc_paddle_x   ),
        .rect_y      ( pc_paddle_y   ),
        .pixel_x     ( vga_x_pos     ),
        .pixel_y     ( vga_y_pos     ),
        .on_sprite_o ( on_pc_paddle  ),
        .vga_rgb_o   ( pc_paddle_rgb )
    );

    // Display ball
    sprite_display #(
        .RECT_W    ( BALL_SIDE ),
        .RECT_H    ( BALL_SIDE )
    ) i_ball (
        .clk_i       ( clk_i       ),
        .rst_i       ( rst_i       ),
        .rect_x      ( ball_x      ),
        .rect_y      ( ball_y      ),
        .pixel_x     ( vga_x_pos   ),
        .pixel_y     ( vga_y_pos   ),
        .on_sprite_o ( on_ball     ),
        .vga_rgb_o   ( ball_rgb    )
    );

    // Output colors based on coordinates
    always_comb begin
        vga_rgb_w = '0;

        if (vga_visible_range) begin
            // Colors might overlap, but we're fine with any case
            unique case (1'b1)
                on_player_paddle: vga_rgb_w = player_paddle_rgb;
                on_pc_paddle    : vga_rgb_w = pc_paddle_rgb;
                on_ball         : vga_rgb_w = ball_rgb;
            endcase

            // Display static separator
            if (vga_x_pos > SCREEN_H_RES / 2 - SEPARATOR_WIDTH / 2 &&
                vga_x_pos < SCREEN_H_RES / 2 + SEPARATOR_WIDTH / 2 &&
               (vga_y_pos + 9 & 31) < SEPARATOR_DOT_HEIGHT)
                vga_rgb_w = '1;
        end
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            vga_rgb_o <= '0;
        else
            vga_rgb_o <= vga_rgb_w;

    always_ff @(posedge clk_i)
        if (rst_i)
            vga_vs_prev <= '0;
        else
            vga_vs_prev <= vga_vs_o;

    always_ff @(posedge clk_i)
        if (rst_i)
            new_frame_o <= '0;
        else
            new_frame_o <= vga_vs_prev && ~vga_vs_o;

    always_ff @(posedge clk_i)
        if (rst_i) begin
            player_paddle_x <= '0;
            player_paddle_y <= '0;

            pc_paddle_x     <= '0;
            pc_paddle_y     <= '0;

            ball_x          <= '0;
            ball_y          <= '0;
        end else if (new_frame_o) begin
            player_paddle_x <= player_paddle_x_i;
            player_paddle_y <= player_paddle_y_i;

            pc_paddle_x     <= pc_paddle_x_i;
            pc_paddle_y     <= pc_paddle_y_i;

            ball_x          <= ball_x_i;
            ball_y          <= ball_y_i;
        end

endmodule
