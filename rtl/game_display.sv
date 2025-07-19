`include "display_pkg.svh"
`include "sprite_pkg.svh"

module game_display
    import display_pkg::COLOR_W,
           display_pkg::RGB_W,
           display_pkg::X_POS_W,
           display_pkg::Y_POS_W,
           display_pkg::SCREEN_H_RES,
           sprite_pkg::N_SPRITES,
           sprite_pkg::PADDLE_WIDTH,
           sprite_pkg::PADDLE_HEIGHT,
           sprite_pkg::BALL_SIDE,
           sprite_pkg::SEPARATOR_WIDTH,
           sprite_pkg::SEPARATOR_DOT_HEIGHT;
(
    input  logic         clk_i,
    input  logic         rst_i,

    output logic         new_frame_o,

    sprite_if.display_mp sprites_i [N_SPRITES],
    score_if.display_mp  score_i,
    display_if           display
);

    logic [COLOR_W-1:0]   red;
    logic [COLOR_W-1:0]   green;
    logic [COLOR_W-1:0]   blue;

    logic [RGB_W-1:0]     sprite_rgb [N_SPRITES];
    logic [RGB_W-1:0]     score_rgb;
    logic [N_SPRITES-1:0] on_sprite;
    logic                 on_score;

    logic [  X_POS_W-1:0] x_pos;
    logic [  Y_POS_W-1:0] y_pos;

    logic                 vsync;
    logic                 vsync_prev;

    `ifdef DVI

        dvi_top i_dvi_top (
            .serial_clk_i ( display.serial_clk  ),
            .pixel_clk_i  ( clk_i               ),
            .rst_i        ( rst_i               ),

            .red_i        ( red                 ),
            .green_i      ( green               ),
            .blue_i       ( blue                ),

            .x_o          ( x_pos               ),
            .y_o          ( y_pos               ),

            .vsync_o      ( vsync               ),

            .tmds_data_p  ( display.tmds_data_p ),
            .tmds_data_n  ( display.tmds_data_n ),

            .tmds_clk_p   ( display.tmds_clk_p  ),
            .tmds_clk_n   ( display.tmds_clk_n  )
        );

    `elsif VGA

        logic visible_range;

        always_ff @(posedge clk_i)
            if (rst_i)
                display.vga_rgb <= '0;
            else
                display.vga_rgb <= visible_range ? { red, green, blue } : '0;

        assign vsync = display.vga_vs;

        vga i_vga (
            .clk_i           ( clk_i          ),
            .rst_i           ( rst_i          ),
            .hsync_o         ( display.vga_hs ),
            .vsync_o         ( display.vga_vs ),
            .pixel_x_o       ( x_pos          ),
            .pixel_y_o       ( y_pos          ),
            .visible_range_o ( visible_range  )
        );

    `endif

    genvar i;
    generate
        for (i = 0; i < N_SPRITES; i++) begin : sprite_display
            sprite_display i_player (
                .clk_i         ( clk_i          ),
                .rst_i         ( rst_i          ),
                .pixel_x_i     ( x_pos          ),
                .pixel_y_i     ( y_pos          ),
                .on_sprite_o   ( on_sprite  [i] ),
                .display_rgb_o ( sprite_rgb [i] ),
                .sprite_i      ( sprites_i  [i] )
            );
        end
    endgenerate

    score_display i_score_display (
        .clk_i         ( clk_i     ),
        .rst_i         ( rst_i     ),
        .pixel_x_i     ( x_pos     ),
        .pixel_y_i     ( y_pos     ),
        .on_score_o    ( on_score  ),
        .display_rgb_o ( score_rgb ),
        .score_i       ( score_i   )
    );

    // Output colors based on coordinates
    always_comb begin
        { red, green, blue } = '0;

        // Score is in the "background", thus other sprites overwrite it
        if (on_score)
            { red, green, blue } = score_rgb;

        for (int n = 0; n < N_SPRITES; n++) begin
            if (on_sprite[n]) begin
                { red, green, blue } = sprite_rgb[n];
            end
        end

        // Display static separator
        if (x_pos > SCREEN_H_RES / 2 - SEPARATOR_WIDTH / 2 &&
            x_pos < SCREEN_H_RES / 2 + SEPARATOR_WIDTH / 2 &&
           (y_pos + 9 & 31) < SEPARATOR_DOT_HEIGHT)
           begin
                { red, green, blue } = '1;
           end
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            vsync_prev <= '0;
        else
            vsync_prev <= vsync;

    always_ff @(posedge clk_i)
        if (rst_i)
            new_frame_o <= '0;
        else
            new_frame_o <= vsync_prev && !vsync;

endmodule
