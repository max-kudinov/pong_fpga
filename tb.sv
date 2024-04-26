module tb;

    localparam CLK_PERIOD = 10;

    logic clk;
    logic rst;
    logic hsync;
    logic vsync;

    game_top dut (
        .clk_i (clk),
        .rst_n_i (rst),
        .vga_vs_o (vsync),
        .vga_hs_o (hsync)
    );

    initial begin
        rst = 0;
        #40;
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
        for (int i = 0;  i < 10000; i++)
            @(posedge clk);

        $finish();
    end
endmodule
