`ifndef SPRITE_PKG_SVH
`define SPRITE_PKG_SVH

`include "display_pkg.svh"

package sprite_pkg;

    import display_pkg::X_POS_W;
    import display_pkg::Y_POS_W;
    import display_pkg::SCREEN_V_RES;
    import display_pkg::SCREEN_H_RES;

    parameter N_SPRITES            = 3;
    parameter N_HITBOXES           = 3;

    parameter PADDLE_WIDTH         = 10;
    parameter PADDLE_HEIGHT        = 50;
    parameter PADDLE_PADDING       = 30;

    parameter PLAYER_SPEED         = 500;
    parameter ENEMY_SPEED          = 250;

    parameter BALL_SIDE            = 10;
    parameter SPEED_W              = 5;
    parameter DEFLECT_SPEED_X      = (SPEED_W-2)'('b100);
    parameter DEFLECT_SPEED_Y      = (SPEED_W-1)'('b0001);
    parameter SIDE_HIT_SPEED_Y     = (SPEED_W-1)'('b0101);
    parameter INIT_SPEED_B         = (SPEED_W)  '('b00100);

    parameter SCREEN_BORDER        = 10;
    parameter SEPARATOR_WIDTH      = 6;
    parameter SEPARATOR_DOT_HEIGHT = 18;

    parameter DOWN_LIMIT           = X_POS_W' (SCREEN_V_RES - (SCREEN_BORDER + PADDLE_HEIGHT));
    parameter PADDLE_CENTER        = X_POS_W' (PADDLE_HEIGHT / 2);

    typedef struct packed {
        logic [X_POS_W-1:0] x_pos;
        logic [Y_POS_W-1:0] y_pos;
        logic [X_POS_W-1:0] right;
        logic [Y_POS_W-1:0] bottom;
    } sprite_t;

    parameter V_CENTER           = Y_POS_W' (SCREEN_V_RES / 2 - 32'(PADDLE_CENTER));
    parameter INIT_PLAYER_X      = SCREEN_H_RES - PADDLE_PADDING;
    parameter INIT_PLAYER_Y      = V_CENTER;
    parameter INIT_ENEMY_X       = PADDLE_PADDING;
    parameter INIT_ENEMY_Y       = V_CENTER;
    parameter INIT_BALL_X        = SCREEN_H_RES / 2 - BALL_SIDE / 2;
    parameter INIT_BALL_Y        = SCREEN_V_RES / 2 - BALL_SIDE / 2;

    parameter sprite_t INIT_ST_P = '{ INIT_PLAYER_X,
                                      INIT_PLAYER_Y,
                                      INIT_PLAYER_X + PADDLE_WIDTH,
                                      INIT_PLAYER_Y + PADDLE_HEIGHT
                                      };

    parameter sprite_t INIT_ST_E = '{ INIT_ENEMY_X,
                                      INIT_ENEMY_Y,
                                      INIT_ENEMY_X + PADDLE_WIDTH,
                                      INIT_ENEMY_Y + PADDLE_HEIGHT
                                      };

    parameter sprite_t INIT_ST_B = '{ INIT_BALL_X,
                                      INIT_BALL_Y,
                                      INIT_BALL_X + BALL_SIDE,
                                      INIT_BALL_Y + BALL_SIDE
                                      };

endpackage : sprite_pkg

`endif
