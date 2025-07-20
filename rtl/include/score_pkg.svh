`ifndef SCORE_PKG_SVH
`define SCORE_PKG_SVH

`include "display_pkg.svh"

package score_pkg;

    import display_pkg::X_POS_W;
    import display_pkg::Y_POS_W;
    import display_pkg::SCREEN_H_RES;

    parameter MAX_SCORE   = 5;
    parameter MAX_SCORE_W = 4; // 4 to cover 0..9

    parameter P_SCORE_X   = X_POS_W' (SCREEN_H_RES - 120);
    parameter P_SCORE_Y   = Y_POS_W' (50);

    parameter E_SCORE_X   = X_POS_W' (120);
    parameter E_SCORE_Y   = Y_POS_W' (50);

    parameter SCALE_POW_2 = 3;
    parameter SCORE_W     = 3;
    parameter SCORE_H     = 5;

    typedef enum logic {
        ST_WAIT_START,
        ST_PLAY
    } state_e;

    // Endianness is changed for ease of display

    // verilator lint_off ASCRANGE

    typedef logic [0:SCORE_H-1][0:SCORE_W-1] score_t;

    typedef enum logic [0:SCORE_H-1][0:SCORE_W-1] {
        ZERO  = { 1'b1, 1'b1, 1'b1,
                  1'b1, 1'b0, 1'b1,
                  1'b1, 1'b0, 1'b1,
                  1'b1, 1'b0, 1'b1,
                  1'b1, 1'b1, 1'b1 },

        ONE   = { 1'b0, 1'b1, 1'b0,
                  1'b0, 1'b1, 1'b0,
                  1'b0, 1'b1, 1'b0,
                  1'b0, 1'b1, 1'b0,
                  1'b0, 1'b1, 1'b0 },

        TWO   = { 1'b1, 1'b1, 1'b1,
                  1'b0, 1'b0, 1'b1,
                  1'b1, 1'b1, 1'b1,
                  1'b1, 1'b0, 1'b0,
                  1'b1, 1'b1, 1'b1 },

        THREE = { 1'b1, 1'b1, 1'b1,
                  1'b0, 1'b0, 1'b1,
                  1'b1, 1'b1, 1'b1,
                  1'b0, 1'b0, 1'b1,
                  1'b1, 1'b1, 1'b1 },

        FOUR  = { 1'b1, 1'b0, 1'b1,
                  1'b1, 1'b0, 1'b1,
                  1'b1, 1'b1, 1'b1,
                  1'b0, 1'b0, 1'b1,
                  1'b0, 1'b0, 1'b1 },

        FIVE  = { 1'b1, 1'b1, 1'b1,
                  1'b1, 1'b0, 1'b0,
                  1'b1, 1'b1, 1'b1,
                  1'b0, 1'b0, 1'b1,
                  1'b1, 1'b1, 1'b1 },

        SIX   = { 1'b1, 1'b1, 1'b1,
                  1'b1, 1'b0, 1'b0,
                  1'b1, 1'b1, 1'b1,
                  1'b1, 1'b0, 1'b1,
                  1'b1, 1'b1, 1'b1 },

        SEVEN = { 1'b1, 1'b1, 1'b1,
                  1'b0, 1'b0, 1'b1,
                  1'b0, 1'b0, 1'b1,
                  1'b0, 1'b0, 1'b1,
                  1'b0, 1'b0, 1'b1 },

        EIGHT = { 1'b1, 1'b1, 1'b1,
                  1'b1, 1'b0, 1'b1,
                  1'b1, 1'b1, 1'b1,
                  1'b1, 1'b0, 1'b1,
                  1'b1, 1'b1, 1'b1 },

        NEIN  = { 1'b1, 1'b1, 1'b1,
                  1'b1, 1'b0, 1'b1,
                  1'b1, 1'b1, 1'b1,
                  1'b0, 1'b0, 1'b1,
                  1'b1, 1'b1, 1'b1 }
    } score_e;

    // verilator lint_on ASCRANGE

endpackage : score_pkg

`endif
