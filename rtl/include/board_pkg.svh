`ifndef BOARD_PKG_SVH
`define BOARD_PKG_SVH

package board_pkg;

    `ifdef PRIMER20K
        `define DVI
    `elsif ZEOWAA
        `define VGA
    `else
        initial $error("Wrong board configuration, either PRIMER20K or ZEOWAA should be defined")
    `endif

    `ifdef PRIMER20K
        parameter BOARD_CLK_MHZ = 25; // Pixel clock is used for everything
        parameter KEYS_W        = 3;
        parameter LEDS_W        = 2;
    `elsif ZEOWAA
        parameter BOARD_CLK_MHZ = 50;
        parameter KEYS_W        = 3;
        parameter LEDS_W        = 2;
    `endif

endpackage : board_pkg

`endif
