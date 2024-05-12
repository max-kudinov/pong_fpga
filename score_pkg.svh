`ifndef SCORE_PKG_SVH
`define SCORE_PKG_SVH

`include "vga_pkg.svh"

package score_pkg;

    import vga_pkg::X_POS_W;
    import vga_pkg::Y_POS_W;
    import vga_pkg::SCREEN_H_RES;

    parameter MAX_SCORE = 5;
    parameter M_SCORE_W = 4; // 4 to cover 0..9

    parameter PS_X = SCREEN_H_RES - 120;
    parameter PS_Y = 50;

    parameter ES_X = 120;
    parameter ES_Y = 50;

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
