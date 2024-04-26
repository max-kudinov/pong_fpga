module game_top
# (
    parameter CLK_MHZ = 50,
    parameter H_RES   = 640,
    parameter V_RES   = 480
)
(
    input  logic       clk_i,
    input  logic       rst_n_i,
    input  logic [1:0] key_i,
    output logic [2:0] vga_rgb_o,
    output logic       vga_vs_o,
    output logic       vga_hs_o,
    output logic       led_o
);

    localparam x_w = $clog2(H_RES);
    localparam y_w = $clog2(V_RES);

    logic [x_w - 1:0] x_pos;
    logic [y_w - 1:0] y_pos;
    logic             visible_range;

    wire rst = ~rst_n_i;

    vga # (
        .CLK_MHZ ( CLK_MHZ ),
        .H_RES   ( H_RES   ),
        .V_RES   ( V_RES   ),
        .X_POS_W ( x_w     ),
        .Y_POS_W ( y_w     )
    )
    i_vga (
        .clk_i           ( clk_i         ),
        .rst_i           ( rst           ),
        .hsync_o         ( vga_hs_o      ),
        .vsync_o         ( vga_vs_o      ),
        .x_pos_o         ( x_pos         ),
        .y_pos_o         ( y_pos         ),
        .visible_range_o ( visible_range )
    );


    always_comb begin
        vga_rgb_o = {1'b0, 1'b0, 1'b0};

        if (visible_range) begin
            if ((x_pos > 300 & x_pos < 400) & (y_pos > 200 & y_pos < 250)) vga_rgb_o = '1;
            // if (x_pos == 320) vga_rgb_o = '1;
            // if (y_pos == 240) vga_rgb_o = '1;
        end
    end

endmodule
