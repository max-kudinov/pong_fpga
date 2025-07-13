`ifndef SCORE_PKG_SVH
`define SCORE_PKG_SVH

`include "display_pkg.svh"

package score_pkg;

    import display_pkg::X_POS_W;
    import display_pkg::Y_POS_W;
    import display_pkg::SCREEN_H_RES;

    parameter MAX_SCORE = 5;
    parameter M_SCORE_W = 4; // 4 to cover 0..9

    parameter P_SCORE_X = X_POS_W' (SCREEN_H_RES - 120);
    parameter P_SCORE_Y = Y_POS_W' (50);

    parameter E_SCORE_X = X_POS_W' (120);
    parameter E_SCORE_Y = Y_POS_W' (50);

    parameter SCALE   = 10;
    parameter SCORE_W = 3 * SCALE;
    parameter SCORE_H = 5 * SCALE;

    typedef enum logic {
        ST_WAIT_START,
        ST_PLAY
    } state_e;

    // Endianness is changed for ease of display

    // verilator lint_off ASCRANGE

    typedef struct packed {
        logic [X_POS_W-1:0]              x_pos;
        logic [Y_POS_W-1:0]              y_pos;
        logic [0:SCORE_H-1][0:SCORE_W-1] score_val;
    } score_t;

    parameter [0:SCORE_H-1][0:SCORE_W-1] score0 = { { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } } };

    parameter [0:SCORE_H-1][0:SCORE_W-1] score1 = { { SCALE { {SCALE{1'b0}}, {SCALE{1'b1}}, {SCALE{1'b0}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b1}}, {SCALE{1'b0}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b1}}, {SCALE{1'b0}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b1}}, {SCALE{1'b0}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b1}}, {SCALE{1'b0}} } } };

    parameter [0:SCORE_H-1][0:SCORE_W-1] score2 = { { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b0}}, {SCALE{1'b0}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } } };

    parameter [0:SCORE_H-1][0:SCORE_W-1] score3 = { { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } } };

    parameter [0:SCORE_H-1][0:SCORE_W-1] score4 = { { SCALE { {SCALE{1'b1}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b0}}, {SCALE{1'b1}} } } };

    parameter [0:SCORE_H-1][0:SCORE_W-1] score5 = { { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b0}}, {SCALE{1'b0}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } } };

    parameter [0:SCORE_H-1][0:SCORE_W-1] score6 = { { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b0}}, {SCALE{1'b0}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } } };

    parameter [0:SCORE_H-1][0:SCORE_W-1] score7 = { { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b0}}, {SCALE{1'b1}} } } };

    parameter [0:SCORE_H-1][0:SCORE_W-1] score8 = { { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } } };

    parameter [0:SCORE_H-1][0:SCORE_W-1] score9 = { { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b0}}, {SCALE{1'b0}}, {SCALE{1'b1}} } },
                                                    { SCALE { {SCALE{1'b1}}, {SCALE{1'b1}}, {SCALE{1'b1}} } } };

    // verilator lint_on ASCRANGE

endpackage : score_pkg

`endif
