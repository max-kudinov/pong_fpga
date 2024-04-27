module vga
# (
    parameter CLK_MHZ       = 50,
    parameter PIXEL_CLK_MHZ = 25,

    parameter H_RES         = 640,
    parameter HSYNC_PULSE   = 96,
    parameter H_FRONT_PORCH = 16,
    parameter H_BACK_PORCH  = 48,
    parameter H_BORDER      = 0,
    parameter X_POS_W       = 10,

    parameter V_RES         = 480,
    parameter VSYNC_PULSE   = 2,
    parameter V_FRONT_PORCH = 10,
    parameter V_BACK_PORCH  = 33,
    parameter V_BORDER      = 0,
    parameter Y_POS_W       = 9
)
(
    input  logic                 clk_i,
    input  logic                 rst_i,
    output logic                 hsync_o,
    output logic                 vsync_o,
    output logic [X_POS_W - 1:0] pixel_x_o,
    output logic [Y_POS_W - 1:0] pixel_y_o,
    output logic                 visible_range_o
);

    // HSYNC
    localparam HSYNC_START  = H_RES + H_BORDER + H_FRONT_PORCH;
    localparam HSYNC_END    = HSYNC_START + HSYNC_PULSE;
    localparam H_TOTAL      = HSYNC_END + H_BACK_PORCH + H_BORDER;

    // VSYNC
    localparam VSYNC_START  = V_RES + V_BORDER + V_FRONT_PORCH;
    localparam VSYNC_END    = VSYNC_START + VSYNC_PULSE;
    localparam V_TOTAL      = VSYNC_END + V_BACK_PORCH + V_BORDER;

    localparam w_clk_en_cnt = $clog2(CLK_MHZ / PIXEL_CLK_MHZ);
    localparam w_h_cnt      = $clog2(H_TOTAL);
    localparam w_v_cnt      = $clog2(V_TOTAL);

    logic [w_clk_en_cnt - 1:0] clk_en_cnt;
    logic                      pixel_clk_en;
    logic                      h_cnt_max;

    logic [     w_h_cnt - 1:0] h_cnt;
    logic [     w_v_cnt - 1:0] v_cnt;

    // Generate enable with pixel clock frequency
    always_ff @(posedge clk_i)
        if (rst_i)
            clk_en_cnt <= '0;
        else
            clk_en_cnt <= clk_en_cnt + 1'b1;

    assign pixel_clk_en = clk_en_cnt == w_clk_en_cnt' ((CLK_MHZ / PIXEL_CLK_MHZ) - 1);
    assign h_cnt_max    = h_cnt == (H_TOTAL - 1);

    // Pixel counter
    always_ff @(posedge clk_i)
        if (rst_i)
            h_cnt <= '0;
        else if (pixel_clk_en) begin
            h_cnt <= h_cnt + 1'b1;

            if (h_cnt_max) h_cnt <= '0;
        end

    // Line counter
    always_ff @(posedge clk_i)
        if (rst_i)
            v_cnt <= '0;
        else if (pixel_clk_en && h_cnt_max) begin
            v_cnt <= v_cnt + 1'b1;

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

            pixel_x_o       <= X_POS_W' (h_cnt);
            pixel_y_o       <= Y_POS_W' (v_cnt);

            visible_range_o <= ((h_cnt < H_RES) && (v_cnt < V_RES));
        end

endmodule
