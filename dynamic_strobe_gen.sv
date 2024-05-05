`include "config.svh"

module dynamic_strobe_gen #(
    parameter FREQ_W = 10,
    parameter CNT_W  = 26
) (
    input  logic              clk_i,
    input  logic              rst_i,
    input  logic [FREQ_W-1:0] strobe_freq,
    output logic              strobe_o
);
    localparam CNT_MAX   = `BOARD_CLK_MHZ * 1_000_000;
    localparam CNT_MAX_W = $clog2(CNT_MAX + 1);

    logic [CNT_W-1:0]     cnt;
    logic [CNT_MAX_W-1:0] cnt_mult;
    logic                 strobe_w;

    always_ff @(posedge clk_i)
        if (rst_i)
            cnt <= '0;
        else if (strobe_w)
            cnt <= '0;
        else
            cnt <= cnt + 1'b1;

    always_ff @(posedge clk_i)
        if (rst_i)
            strobe_o <= '0;
        else
            strobe_o <= strobe_w;

    always_ff @(posedge clk_i)
        if (rst_i)
            cnt_mult <= '0;
        else
            cnt_mult <= cnt * strobe_freq;

    assign strobe_w = cnt_mult > CNT_MAX;

endmodule
