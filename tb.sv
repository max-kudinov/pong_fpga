module tb;

    localparam CLK_PERIOD   = 20;
    localparam RST_DURATION = 40;
    localparam CLOCK_CYCLES = 100_000;

    logic clk;
    logic rst;
    logic [2:0] key;

    assign key = 3'b100;

    // verilator lint_off PINMISSING
    primer20k_board_top dut
    (
        .clk_i     ( clk   ),
        .rst_n_i   ( rst   ),
        .keys_i    ( key   )
    );
    // verilator lint_on PINMISSING

    initial begin
        rst = 0;
        #RST_DURATION;
        rst = 1;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end

    initial begin
        clk = 0;
        forever begin
            #(CLK_PERIOD / 2) clk = ~ clk;
        end
    end

    initial begin
        for (int i = 0;  i < CLOCK_CYCLES; i++)
            @(posedge clk);

        $finish();
    end
endmodule
