`ifndef VGA_PKG_SV
`define VGA_PKG_SV

package vga_pkg;

    parameter SCREEN_H_RES  = 640;
    parameter SCREEN_V_RES  = 480;

    parameter BOARD_CLK_MHZ = 50;
    parameter PIXEL_CLK_MHZ = 25;

    parameter HSYNC_PULSE   = 96;
    parameter H_FRONT_PORCH = 16;
    parameter H_BACK_PORCH  = 48;
    parameter H_BORDER      = 0;

    parameter VSYNC_PULSE   = 2;
    parameter V_FRONT_PORCH = 10;
    parameter V_BACK_PORCH  = 33;
    parameter V_BORDER      = 0;

    // HSYNC
    parameter HSYNC_START   = SCREEN_H_RES + H_BORDER + H_FRONT_PORCH;
    parameter HSYNC_END     = HSYNC_START + HSYNC_PULSE;
    parameter H_TOTAL       = HSYNC_END + H_BACK_PORCH + H_BORDER;

    // VSYNC
    parameter VSYNC_START   =  SCREEN_V_RES + V_BORDER + V_FRONT_PORCH;
    parameter VSYNC_END     = VSYNC_START + VSYNC_PULSE;
    parameter V_TOTAL       = VSYNC_END + V_BACK_PORCH + V_BORDER;

    parameter X_POS_W       = $clog2(H_TOTAL);
    parameter Y_POS_W       = $clog2(V_TOTAL);

    parameter PX_CNT_W      = $clog2(BOARD_CLK_MHZ / PIXEL_CLK_MHZ);

endpackage : vga_pkg

`endif
