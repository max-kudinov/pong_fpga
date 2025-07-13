`include "board_pkg.svh"
`include "display_pkg.svh"

module vga
    import display_pkg::*,
           board_pkg::BOARD_CLK_MHZ;
(
    input  logic               clk_i,
    input  logic               rst_i,
    output logic               hsync_o,
    output logic               vsync_o,
    output logic [X_POS_W-1:0] pixel_x_o,
    output logic [Y_POS_W-1:0] pixel_y_o,
    output logic               visible_range_o
);

    logic [PX_CNT_W-1:0] pixel_clk_cnt;
    logic                pixel_clk_en;
    logic                h_cnt_max;

    logic  [X_POS_W-1:0] h_cnt;
    logic  [Y_POS_W-1:0] v_cnt;

    // Generate enable for pixel clock frequency
    always_ff @(posedge clk_i)
        if (rst_i)
            pixel_clk_cnt <= '0;
        else
            pixel_clk_cnt <= pixel_clk_cnt + 1'b1;

    assign pixel_clk_en = pixel_clk_cnt == PX_CNT_W' ((BOARD_CLK_MHZ / PIXEL_CLK_MHZ) - 1);
    assign h_cnt_max    = h_cnt == (H_TOTAL - 1);

    // Pixel counter
    always_ff @(posedge clk_i)
        if (rst_i)
            h_cnt     <= '0;
        else if (pixel_clk_en) begin
            h_cnt     <= h_cnt + 1'b1;

            if (h_cnt_max)
                h_cnt <= '0;
        end

    // Line counter
    always_ff @(posedge clk_i)
        if (rst_i)
            v_cnt     <= '0;
        else if (pixel_clk_en && h_cnt_max) begin
            v_cnt     <= v_cnt + 1'b1;

            if (v_cnt == (V_TOTAL - 1))
                v_cnt <= '0;
        end

    // Register outputs
    always_ff @(posedge clk_i)
        if (rst_i) begin
            hsync_o         <= '0;
            vsync_o         <= '0;
            pixel_x_o       <= '0;
            pixel_y_o       <= '0;
            visible_range_o <= '0;
        end else if (pixel_clk_en) begin
            hsync_o         <= ~ (h_cnt >= HSYNC_START && h_cnt < HSYNC_END);
            vsync_o         <= ~ (v_cnt >= VSYNC_START && v_cnt < VSYNC_END);

            pixel_x_o       <= h_cnt;
            pixel_y_o       <= v_cnt;

            visible_range_o <= ((h_cnt < SCREEN_H_RES) && (v_cnt < SCREEN_V_RES));
        end

endmodule
