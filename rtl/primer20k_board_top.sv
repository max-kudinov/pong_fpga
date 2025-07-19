`include "board_pkg.svh"

`ifdef PRIMER20K

module primer20k_board_top
    import board_pkg::*;
(
    input  logic                 clk_i,
    input  logic                 rst_n_i,
    input  logic [   KEYS_W-1:0] keys_inv_i,
    output logic [   LEDS_W-1:0] leds_inv_o,
    output logic [          2:0] tmds_data_p,
    output logic [          2:0] tmds_data_n,
    output logic                 tmds_clk_p,
    output logic                 tmds_clk_n
);

    display_if display ();

    // verilator lint_off UNUSEDSIGNAL
    // verilator lint_off UNDRIVEN
    logic              pixel_clk;
    logic              pixel_clk_div2;
    logic              serial_clk;
    logic              pll_lock;
    // verilator lint_on UNDRIVEN
    // verilator lint_on UNUSEDSIGNAL
    logic              rst;
    logic              upload_rst_n;
    logic [KEYS_W-1:0] keys;
    logic [LEDS_W-1:0] leds;

    // Reset on upload
    initial begin
        upload_rst_n = '0;
    end

    always_ff @(posedge pixel_clk)
        upload_rst_n <= '1;

    // Invert board signals
    assign rst        = ~rst_n_i || ~upload_rst_n;
    assign keys       = ~keys_inv_i;
    assign leds_inv_o = ~leds;

    // Unwrap interface signals
    assign display.serial_clk = serial_clk;
    assign tmds_data_p        = display.tmds_data_p;
    assign tmds_data_n        = display.tmds_data_n;
    assign tmds_clk_p         = display.tmds_clk_p;
    assign tmds_clk_n         = display.tmds_clk_n;

    `ifndef VERILATOR

        rPLL #(
            .FCLKIN    ( "27" ),
            .IDIV_SEL  ( 2    ),
            .FBDIV_SEL ( 27   ),
            .ODIV_SEL  ( 4    )
        ) rpll_inst (
            .CLKIN   ( clk_i      ), // 27 MHZ
            .CLKOUT  ( serial_clk ), // 252 MHz
            .LOCK    ( pll_lock   ),
            .RESET   ( '0         ),
            .RESET_P ( '0         ),
            .CLKFB   ( '0         ),
            .FBDSEL  ( '0         ),
            .IDSEL   ( '0         ),
            .ODSEL   ( '0         ),
            .PSDA    ( '0         ),
            .DUTYDA  ( '0         ),
            .FDLY    ( '0         )
        );

        // Divide by 10 to get 25.2 MHz pixel clock

        CLKDIV2 div_2 (
            .HCLKIN ( serial_clk     ),
            .CLKOUT ( pixel_clk_div2 ),
            .RESETN ( pll_lock       )
        );

        CLKDIV #(
            .DIV_MODE ("5")
        ) div_5 (
            .HCLKIN ( pixel_clk_div2 ),
            .CLKOUT ( pixel_clk      ),
            .RESETN ( pll_lock       )
        );

    `endif

    game_top i_game_top (
        .clk_i       (  pixel_clk ),
        .rst_i       (  rst       ),
        .keys_i      (  keys      ),
        .leds_o      (  leds      ),
        .display     ( display    )
    );

endmodule

`endif
