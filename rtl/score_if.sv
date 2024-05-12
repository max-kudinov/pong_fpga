`include "score_pkg.svh"

interface score_if;
    import score_pkg::score_t;

    score_t player;
    score_t enemy;

    modport display_mp (
        input player,
        input enemy
    );

    modport control_mp (
        output player,
        output enemy
    );

endinterface : score_if
