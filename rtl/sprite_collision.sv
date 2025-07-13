`include "display_pkg.svh"
`include "sprite_pkg.svh"

module sprite_collision
    import display_pkg::X_POS_W,
           display_pkg::Y_POS_W,
           sprite_pkg::sprite_t;
(
    input  logic                  clk_i,
    input  logic                  rst_i,

    sprite_if                     rect_1_i,
    sprite_if                     rect_2_i,

    output logic                  collision_o
);

    sprite_t rect_1;
    sprite_t rect_2;

    assign rect_1 = rect_1_i.sprite;
    assign rect_2 = rect_2_i.sprite;

    // x_pos is left and y_pos is top
    always_ff @(posedge clk_i)
        if (rst_i)
            collision_o <= '0;
        else
            collision_o <= ((rect_1.right  > rect_2.x_pos) &&
                            (rect_2.right  > rect_1.x_pos) &&
                            (rect_2.bottom > rect_1.y_pos) &&
                            (rect_1.bottom > rect_2.y_pos));
endmodule
