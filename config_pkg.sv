package config_pkg;
    `timescale 1ns / 100ps

    parameter BOARD_CLK_MHZ = 50;
    parameter PIXEL_CLK_MHZ = 25;

    parameter KEYS_W        = 2;
    parameter LEDS_W        = 2;
    parameter VGA_RGB_W     = 3;

    parameter HSYNC_PULSE   = 96;
    parameter H_FRONT_PORCH = 16;
    parameter H_BACK_PORCH  = 48;
    parameter H_BORDER      = 0;

    parameter VSYNC_PULSE   = 2;
    parameter V_FRONT_PORCH = 10;
    parameter V_BACK_PORCH  = 33;
    parameter V_BORDER      = 0;

    parameter SCREEN_H_RES  = 640;
    parameter SCREEN_V_RES  = 480;

    // HSYNC
    parameter HSYNC_START   = SCREEN_H_RES + H_BORDER + H_FRONT_PORCH;
    parameter HSYNC_END     = HSYNC_START + HSYNC_PULSE;
    parameter H_TOTAL       = HSYNC_END + H_BACK_PORCH + H_BORDER;

    // VSYNC
    parameter VSYNC_START   =  SCREEN_V_RES + V_BORDER + V_FRONT_PORCH;
    parameter VSYNC_END     = VSYNC_START + VSYNC_PULSE;
    parameter V_TOTAL       = VSYNC_END + V_BACK_PORCH + V_BORDER;

    parameter PX_CNT_W      = $clog2(BOARD_CLK_MHZ / PIXEL_CLK_MHZ);
  
    parameter X_POS_W       = $clog2(H_TOTAL);
    parameter Y_POS_W       = $clog2(V_TOTAL);

    parameter RND_NUM_W     = 9;
    parameter RND_SEED      = 1337;
    parameter TAPS          = 'h110;

    parameter PADDLE_WIDTH  = 10;
    parameter PADDLE_HEIGHT = 50;

    parameter PLAYER_SPEED    = 700;
    parameter ENEMY_SPEED     = 250;
    parameter BALL_BASE_SPEED = 60;

    parameter [Y_POS_W-1:0] DOWN_LIMIT    = SCREEN_V_RES - (SCREEN_BORDER + PADDLE_HEIGHT);
    parameter [Y_POS_W-1:0] PADDLE_CENTER = PADDLE_HEIGHT / 2;

    parameter V_CENTER = Y_POS_W' (SCREEN_V_RES / 2 - 32'(PADDLE_CENTER));

    parameter BALL_SIDE = 10;
    parameter SPEED_W = 5;
    parameter DEFLECT_SPEED_X = (SPEED_W-2)'(100);
    parameter DEFLECT_SPEED_Y = (SPEED_W-1)'(0001);
    parameter SIDE_HIT_SPEED_Y = (SPEED_W-1)'(0101);

    parameter SCREEN_BORDER = 10;
    parameter SEPARATOR_WIDTH = 6;
    parameter SEPARATOR_DOT_HEIGHT = 18;

    typedef struct packed {
        logic [X_POS_W-1:0] x_pos;
        logic [Y_POS_W-1:0] y_pos;
        logic [X_POS_W-1:0] right;
        logic [Y_POS_W-1:0] bottom;
    } sprite_t;

endpackage : config_pkg

