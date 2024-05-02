`include "config.svh"

module game_display (
    input  logic                    clk_i,
    input  logic                    rst_i,
 
    input  logic [`X_POS_W - 1:0]   vga_x_pos_i,
    input  logic [`Y_POS_W - 1:0]   vga_y_pos_i,

    input  logic [`X_POS_W - 1:0]   player_paddle_x_i,
    input  logic [`Y_POS_W - 1:0]   player_paddle_y_i,

    input  logic [`X_POS_W - 1:0]   pc_paddle_x_i,
    input  logic [`Y_POS_W - 1:0]   pc_paddle_y_i,

    input  logic [`X_POS_W - 1:0]   ball_x_i,
    input  logic [`Y_POS_W - 1:0]   ball_y_i,
    
    input  logic                    vga_visible_range_i,
    output logic [`VGA_RGB_W - 1:0] vga_rgb_o 
);
    logic [`VGA_RGB_W - 1:0] vga_rgb_w;
    logic [`VGA_RGB_W - 1:0] player_paddle_rgb;
    logic [`VGA_RGB_W - 1:0] pc_paddle_rgb;
    logic [`VGA_RGB_W - 1:0] ball_rgb;

    logic                    on_player_paddle;
    logic                    on_pc_paddle;
    logic                    on_ball;

    // Display player paddle
    sprite_display #(
        .RECT_W    ( `PLAYER_PADDLE_WIDTH  ),
        .RECT_H    ( `PLAYER_PADDLE_HEIGHT )
    ) i_player (
        .rect_x    ( player_paddle_x_i ),
        .rect_y    ( player_paddle_y_i ),
        .pixel_x   ( vga_x_pos_i       ),
        .pixel_y   ( vga_y_pos_i       ),
        .on_sprite ( on_player_paddle  ),
        .vga_rgb_o ( player_paddle_rgb )
    );

    // Display computer paddle
    sprite_display #(
        .RECT_W    ( `PC_PADDLE_WIDTH  ),
        .RECT_H    ( `PC_PADDLE_HEIGHT )
    ) i_computer (
        .rect_x    ( pc_paddle_x_i ),
        .rect_y    ( pc_paddle_y_i ),
        .pixel_x   ( vga_x_pos_i   ),
        .pixel_y   ( vga_y_pos_i   ),
        .on_sprite ( on_pc_paddle  ),
        .vga_rgb_o ( pc_paddle_rgb )
    );

    // Display ball
    sprite_display #(
        .RECT_W    ( `BALL_SIDE ),
        .RECT_H    ( `BALL_SIDE )
    ) i_ball (
        .rect_x    ( ball_x_i    ),
        .rect_y    ( ball_y_i    ),
        .pixel_x   ( vga_x_pos_i ),
        .pixel_y   ( vga_y_pos_i ),
        .on_sprite ( on_ball     ),
        .vga_rgb_o ( ball_rgb    )
    );

    // Output colors based on coordinates
    always_comb begin
        vga_rgb_w = '0;

        if (vga_visible_range_i) begin
            // Colors might overlap, but we're fine with any case
            unique case (1'b1)
                on_player_paddle: vga_rgb_w = player_paddle_rgb;
                on_pc_paddle    : vga_rgb_w = pc_paddle_rgb;
                on_ball         : vga_rgb_w = ball_rgb;
            endcase
        end
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            vga_rgb_o <= '0;
        else
            vga_rgb_o <= vga_rgb_w;

endmodule
