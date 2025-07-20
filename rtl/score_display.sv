`include "score_pkg.svh"
`include "display_pkg.svh"

module score_display
    import score_pkg::*,
           display_pkg::RGB_W,
           display_pkg::X_POS_W,
           display_pkg::Y_POS_W;
(
    input  logic                            clk_i,
    input  logic                            rst_i,
    input  logic              [X_POS_W-1:0] pixel_x_i,
    input  logic              [Y_POS_W-1:0] pixel_y_i,
    input  score_t                          player_score_i,
    input  score_t                          enemy_score_i,
    output logic                            on_score_o,
    output logic              [RGB_W-1:0]   display_rgb_o
);

    localparam SCORE_PIXEL_WIDTH  = SCORE_W * (2**SCALE_POW_2);
    localparam SCORE_PIXEL_HEIGHT = SCORE_H * (2**SCALE_POW_2);

    logic [RGB_W-1:0] display_rgb_w;
    logic             on_score_w;

    always_comb begin
        display_rgb_w = '0;
        on_score_w    = '0;

        if (pixel_x_i >= P_SCORE_X &&
            pixel_x_i < (P_SCORE_X + SCORE_PIXEL_WIDTH) &&
            pixel_y_i >= P_SCORE_Y &&
            pixel_y_i < (P_SCORE_Y + SCORE_PIXEL_HEIGHT)
            ) begin

            on_score_w = '1;

            if (player_score_i[(pixel_y_i - P_SCORE_Y) >> SCALE_POW_2]
                              [(pixel_x_i - P_SCORE_X) >> SCALE_POW_2]) begin
                display_rgb_w = '1;
            end

        end

        if (pixel_x_i >= E_SCORE_X &&
            pixel_x_i < (E_SCORE_X + SCORE_PIXEL_WIDTH) &&
            pixel_y_i >= E_SCORE_Y &&
            pixel_y_i < (E_SCORE_Y + SCORE_PIXEL_HEIGHT)
            ) begin

            on_score_w = '1;

            if (enemy_score_i[(pixel_y_i - E_SCORE_Y) >> SCALE_POW_2]
                             [(pixel_x_i - E_SCORE_X) >> SCALE_POW_2]) begin
                display_rgb_w = '1;
            end

        end
    end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            display_rgb_o <= '0;
            on_score_o    <= '0;
        end else begin
            display_rgb_o <= display_rgb_w;
            on_score_o    <= on_score_w;
        end

endmodule
