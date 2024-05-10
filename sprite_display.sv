`include "board_pkg.svh"
`include "vga_pkg.svh"

module sprite_display
    import board_pkg::VGA_RGB_W;
    import vga_pkg::X_POS_W;
    import vga_pkg::Y_POS_W;

#(
    parameter RECT_W = 10,
    parameter RECT_H = 10
) (
    input  logic                    clk_i,
    input  logic                    rst_i,
    input  logic [  X_POS_W - 1:0] rect_x,
    input  logic [  Y_POS_W - 1:0] rect_y,
    input  logic [  X_POS_W - 1:0] pixel_x,
    input  logic [  Y_POS_W - 1:0] pixel_y,
    output logic [VGA_RGB_W - 1:0] vga_rgb_o,
    output logic                    on_sprite_o
);

    logic [VGA_RGB_W-1:0] vga_rgb_w;
    logic                  on_sprite_w;

    always_comb begin
        vga_rgb_w   = '0;
        on_sprite_w = '0;

        if (pixel_x > rect_x && pixel_x < rect_x + RECT_W &&
           (pixel_y > rect_y && pixel_y < rect_y + RECT_H)) begin
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
