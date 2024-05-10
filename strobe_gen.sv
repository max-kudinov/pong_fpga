module strobe_gen #(
    parameter STROBE_FREQ_HZ = 1
) (
    input  logic clk_i,
    input  logic rst_i,
    output logic strobe
);

    localparam CNT_MAX = BOARD_CLK_MHZ * 1_000_000 / STROBE_FREQ_HZ;
    localparam CNT_W   = $clog2(CNT_MAX + 1);

    logic [CNT_W - 1:0] cnt;

    always_ff @(posedge clk_i)
        if (rst_i)
            cnt <= '0;
        else if (strobe)
            cnt <= '0;
        else
            cnt <= cnt + CNT_W'(1);

    assign strobe = cnt == CNT_W' (CNT_MAX);

endmodule
