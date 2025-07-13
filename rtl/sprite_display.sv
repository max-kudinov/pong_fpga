`include "display_pkg.svh"
`include "sprite_pkg.svh"

module sprite_display
    import display_pkg::RGB_W,
           display_pkg::X_POS_W,
           display_pkg::Y_POS_W,
           sprite_pkg::sprite_t;
(
    input  logic               clk_i,
    input  logic               rst_i,
    input  logic [X_POS_W-1:0] pixel_x_i,
    input  logic [Y_POS_W-1:0] pixel_y_i,
    output logic [RGB_W-1:0]   display_rgb_o,
    output logic               on_sprite_o,

    sprite_if.display_mp       sprite_i
);

    logic [RGB_W-1:0] display_rgb_w;
    logic             on_sprite_w;
    sprite_t          sprite;

    assign sprite = sprite_i.sprite;

    always_comb begin
        display_rgb_w = '0;
        on_sprite_w   = '0;

        if (pixel_x_i > sprite.x_pos && pixel_x_i < sprite.right &&
           (pixel_y_i > sprite.y_pos && pixel_y_i < sprite.bottom )) begin
            display_rgb_w = '1;
            on_sprite_w   = '1;
        end
    end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            display_rgb_o <= '0;
            on_sprite_o   <= '0;
        end else begin
            display_rgb_o <= display_rgb_w;
            on_sprite_o   <= on_sprite_w;
        end

endmodule
