`ifndef SCORE_PKG_SVH
`define SCORE_PKG_SVH

package score_pkg;

    parameter MAX_SCORE = 5;
    parameter M_SCORE_W = $clog2(MAX_SCORE + 1);

    typedef enum logic {
        ST_WAIT_START,
        ST_PLAY
    } state_e;

endpackage : score_pkg

`endif
