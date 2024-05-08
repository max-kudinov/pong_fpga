`ifndef CONFIG_SVH
`define CONFIG_SVH

`timescale 1ns / 100ps

`define BOARD_CLK_MHZ 50
`define PIXEL_CLK_MHZ 25

`define KEYS_W 2
`define LEDS_W 2
`define VGA_RGB_W 3

`define HSYNC_PULSE 96
`define H_FRONT_PORCH 16
`define H_BACK_PORCH 48
`define H_BORDER 0

`define VSYNC_PULSE   2
`define V_FRONT_PORCH 10
`define V_BACK_PORCH  33
`define V_BORDER      0

`define SCREEN_H_RES 640
`define SCREEN_V_RES 480

// HSYNC
`define HSYNC_START `SCREEN_H_RES + `H_BORDER + `H_FRONT_PORCH
`define HSYNC_END `HSYNC_START + `HSYNC_PULSE
`define H_TOTAL `HSYNC_END + `H_BACK_PORCH + `H_BORDER

// VSYNC
`define VSYNC_START  `SCREEN_V_RES + `V_BORDER + `V_FRONT_PORCH
`define VSYNC_END `VSYNC_START + `VSYNC_PULSE
`define V_TOTAL `VSYNC_END + `V_BACK_PORCH + `V_BORDER

`define PX_CNT_W      $clog2(`BOARD_CLK_MHZ / `PIXEL_CLK_MHZ)

`define X_POS_W $clog2(`H_TOTAL)
`define Y_POS_W $clog2(`V_TOTAL)

`define RND_NUM_W 9
`define RND_SEED 42069

`define PADDLE_WIDTH 10
`define PADDLE_HEIGHT 50

`define PLAYER_SPEED 300
`define PC_SPEED 250
`define BALL_BASE_SPEED 60

`define BALL_SIDE 10
`define BALL_SPEED_W 5

`define SCREEN_BORDER 10 
`define SEPARATOR_WIDTH 6
`define SEPARATOR_DOT_HEIGHT 18

typedef struct packed {
    logic [`X_POS_W - 1:0] x_pos;
    logic [`Y_POS_W - 1:0] y_pos;
    logic [`X_POS_W - 1:0] right;
    logic [`Y_POS_W - 1:0] bottom;
} sprite_t;

`endif
