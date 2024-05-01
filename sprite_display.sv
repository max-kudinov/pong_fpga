`include "config.svh"

module sprite_display #(
    parameter RECT_W = 10,
    parameter RECT_H = 10
) (
    input  logic [  `X_POS_W - 1:0] rect_x,
    input  logic [  `Y_POS_W - 1:0] rect_y,
    input  logic [  `X_POS_W - 1:0] pixel_x,
    input  logic [  `Y_POS_W - 1:0] pixel_y,
    output logic [`VGA_RGB_W - 1:0] vga_rgb_o
);

    always_comb begin
        vga_rgb_o = '0;

        if (pixel_x > rect_x && pixel_x < rect_x + RECT_W &&
           (pixel_y > rect_y && pixel_y < rect_y + RECT_H)) begin
            vga_rgb_o = '1;
        end
    end

endmodule
