`include "board_pkg.svh"
`include "score_pkg.svh"
`include "vga_pkg.svh"

module score_display
    import score_pkg::*,
           board_pkg::VGA_RGB_W,
           vga_pkg::X_POS_W,
           vga_pkg::Y_POS_W;
(
    input  logic                              clk_i,
    input  logic                              rst_i,
    input  logic              [X_POS_W-1:0]   pixel_x_i, 
    input  logic              [Y_POS_W-1:0]   pixel_y_i, 
    output logic                              on_score_o,
    output logic              [VGA_RGB_W-1:0] vga_rgb_o,

    score_if.display_mp                       score_i
);

    logic [VGA_RGB_W-1:0] vga_rgb_w;
    logic                 on_score_w;

    score_t               player_s;
    score_t               enemy_s;

    assign player_s = score_i.player;
    assign enemy_s  = score_i.enemy;

    always_comb begin
        vga_rgb_w  = '0;
        on_score_w = '0;

        if (pixel_x_i >= player_s.x_pos && pixel_x_i < player_s.x_pos + SCORE_W &&
            pixel_y_i >= player_s.y_pos && pixel_y_i < player_s.y_pos + SCORE_H &&
            player_s.score_val[pixel_y_i - player_s.y_pos][pixel_x_i - player_s.x_pos]) begin
            on_score_w = '1;
            vga_rgb_w  = '1; 
        end

        if (pixel_x_i >= enemy_s.x_pos && pixel_x_i < enemy_s.x_pos + SCORE_W &&
            pixel_y_i >= enemy_s.y_pos && pixel_y_i < enemy_s.y_pos + SCORE_H &&
            enemy_s.score_val[pixel_y_i - enemy_s.y_pos][pixel_x_i - enemy_s.x_pos]) begin
            on_score_w = '1;
            vga_rgb_w  = '1; 
        end
    end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            vga_rgb_o  <= '0;
            on_score_o <= '0;
        end else begin
            vga_rgb_o  <= vga_rgb_w;
            on_score_o <= on_score_w;
        end

endmodule
