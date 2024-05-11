`include "vga_pkg.svh"

module sprite_collision
    import vga_pkg::X_POS_W,
           vga_pkg::Y_POS_W;
(
    input  logic                  clk_i,
    input  logic                  rst_i,

    input  logic [X_POS_W - 1:0] rect1_left_i,
    input  logic [X_POS_W - 1:0] rect1_right_i,
    input  logic [Y_POS_W - 1:0] rect1_top_i,
    input  logic [Y_POS_W - 1:0] rect1_bottom_i,

    input  logic [X_POS_W - 1:0] rect2_left_i,
    input  logic [X_POS_W - 1:0] rect2_right_i,
    input  logic [Y_POS_W - 1:0] rect2_top_i,
    input  logic [Y_POS_W - 1:0] rect2_bottom_i,

    output logic                  collision_o
);
    logic [X_POS_W - 1:0] rect1_left;
    logic [X_POS_W - 1:0] rect1_right;
    logic [Y_POS_W - 1:0] rect1_top;
    logic [Y_POS_W - 1:0] rect1_bottom;

    logic [X_POS_W - 1:0] rect2_left;
    logic [X_POS_W - 1:0] rect2_right;
    logic [Y_POS_W - 1:0] rect2_top;
    logic [Y_POS_W - 1:0] rect2_bottom;

    always_ff @(posedge clk_i)
        if (rst_i) begin
            rect1_left   <= '0;
            rect1_right  <= '0;
            rect1_top    <= '0;
            rect1_bottom <= '0;

            rect2_left   <= '0;
            rect2_right  <= '0;
            rect2_top    <= '0;
            rect2_bottom <= '0;
        end else begin
            rect1_left   <= rect1_left_i;
            rect1_right  <= rect1_right_i;
            rect1_top    <= rect1_top_i;
            rect1_bottom <= rect1_bottom_i;

            rect2_left   <= rect2_left_i;
            rect2_right  <= rect2_right_i;
            rect2_top    <= rect2_top_i;
            rect2_bottom <= rect2_bottom_i;
        end

    always_ff @(posedge clk_i)
        if (rst_i)
            collision_o <= '0;
        else
            collision_o <= ((rect1_right  > rect2_left) &&
                            (rect2_right  > rect1_left) &&
                            (rect2_bottom > rect1_top ) &&
                            (rect1_bottom > rect2_top));
endmodule
