`include "board_pkg.svh"
`include "vga_pkg.svh"
`include "sprite_pkg.svh"

module game_display
    import board_pkg::VGA_RGB_W,
           vga_pkg::X_POS_W,
           vga_pkg::Y_POS_W,
           vga_pkg::SCREEN_H_RES,
           sprite_pkg::N_SPRITES,
           sprite_pkg::PADDLE_WIDTH,
           sprite_pkg::PADDLE_HEIGHT,
           sprite_pkg::BALL_SIDE,
           sprite_pkg::SEPARATOR_WIDTH,
           sprite_pkg::SEPARATOR_DOT_HEIGHT;
(
    input  logic                  clk_i,
    input  logic                  rst_i,

    output logic                  vga_hs_o,
    output logic                  vga_vs_o,
    output logic [VGA_RGB_W-1:0]  vga_rgb_o,
    output logic                  new_frame_o,

    sprite_if                     sprites_i [N_SPRITES]
);

    logic [VGA_RGB_W-1:0] sprite_rgb [N_SPRITES];
    logic [N_SPRITES-1:0] on_sprite;

    logic [  X_POS_W-1:0] vga_x_pos;
    logic [  Y_POS_W-1:0] vga_y_pos;
    logic [VGA_RGB_W-1:0] vga_rgb_w;
    logic                 vga_visible_range;
    logic                 vga_vs_prev;

    vga i_vga (
        .clk_i           ( clk_i             ),
        .rst_i           ( rst_i             ),
        .hsync_o         ( vga_hs_o          ),
        .vsync_o         ( vga_vs_o          ),
        .pixel_x_o       ( vga_x_pos         ),
        .pixel_y_o       ( vga_y_pos         ),
        .visible_range_o ( vga_visible_range )
    );

    genvar i;
    generate
        for (i = 0; i < N_SPRITES; i++) begin : sprite_display
            sprite_display i_player (
                .clk_i       ( clk_i          ),
                .rst_i       ( rst_i          ),
                .pixel_x     ( vga_x_pos      ),
                .pixel_y     ( vga_y_pos      ),
                .on_sprite_o ( on_sprite  [i] ),
                .vga_rgb_o   ( sprite_rgb [i] ),
                .sprite_i    ( sprites_i  [i] )
            );
        end
    endgenerate

    // Output colors based on coordinates
    always_comb begin
        vga_rgb_w  = '0;

        if (vga_visible_range) begin

            for (int n = 0; n < N_SPRITES; n++) begin
                if (on_sprite[n])
                    vga_rgb_w = sprite_rgb[n];
            end

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

endmodule
