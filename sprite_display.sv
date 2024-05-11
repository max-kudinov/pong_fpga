`include "board_pkg.svh"
`include "vga_pkg.svh"
`include "sprite_pkg.svh"

module sprite_display
    import board_pkg::VGA_RGB_W,
           vga_pkg::X_POS_W,
           vga_pkg::Y_POS_W,
           sprite_pkg::sprite_t;
(
    input  logic                  clk_i,
    input  logic                  rst_i,
    input  logic [  X_POS_W-1:0]  pixel_x,
    input  logic [  Y_POS_W-1:0]  pixel_y,
    output logic [VGA_RGB_W-1:0]  vga_rgb_o,
    output logic                  on_sprite_o,

    sprite_if                     sprite_i
);

    logic [VGA_RGB_W-1:0] vga_rgb_w;
    logic                 on_sprite_w;
    sprite_t              sprite;

    assign sprite = sprite_i.sprite;

    always_comb begin
        vga_rgb_w   = '0;
        on_sprite_w = '0;

        if (pixel_x > sprite.x_pos && pixel_x < sprite.right &&
           (pixel_y > sprite.y_pos && pixel_y < sprite.bottom )) begin
            vga_rgb_w   = '1;
            on_sprite_w = '1;
        end
    end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            vga_rgb_o   <= '0;
            on_sprite_o <= '0;
        end else begin
            vga_rgb_o   <= vga_rgb_w;
            on_sprite_o <= on_sprite_w;
        end

endmodule
