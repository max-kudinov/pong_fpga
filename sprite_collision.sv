`include "config.svh"

module sprite_collision (
    input  logic                  clk_i,
    input  logic                  rst_i,

    input  logic [`X_POS_W - 1:0] rect1_left,
    input  logic [`X_POS_W - 1:0] rect1_right,
    input  logic [`Y_POS_W - 1:0] rect1_top,
    input  logic [`Y_POS_W - 1:0] rect1_bottom,

    input  logic [`X_POS_W - 1:0] rect2_left,
    input  logic [`X_POS_W - 1:0] rect2_right,
    input  logic [`Y_POS_W - 1:0] rect2_top,
    input  logic [`Y_POS_W - 1:0] rect2_bottom,

    output logic                  collision
);

    always_ff @(posedge clk_i)
        if (rst_i)
            collision <= '0;
        else
            collision <= ((rect1_right  > rect2_left) &&
                          (rect2_right  > rect1_left) &&
                          (rect2_bottom > rect1_top ) &&
                          (rect1_bottom > rect2_top));
endmodule
