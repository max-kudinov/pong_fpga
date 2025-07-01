`ifndef BOARD_PKG_SVH
`define BOARD_PKG_SVH

package board_pkg;

    `ifdef PRIMER20K
        parameter KEYS_W       = 3;
        parameter LEDS_W       = 2;
        parameter VGA_RGB_W    = 24;
        parameter RGB_W        = 24;
        parameter COLOR_W      = 8;
        parameter DISPLAY_TYPE = 1; // 0 - VGA, 1 - DVI (HDMI)
    `elsif ZEOWAA
        parameter KEYS_W       = 3;
        parameter LEDS_W       = 2;
        parameter RGB_W        = 3;
        parameter DISPLAY_TYPE = 0; // 0 - VGA, 1 - DVI (HDMI)
    `else
        initial $error("Wrong board configuration, either PRIMER20K or ZEOWAA should be defined")
    `endif


endpackage : board_pkg

`endif 
