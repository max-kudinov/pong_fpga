`include "sprite_pkg.svh"

interface sprite_if;
    import sprite_pkg::sprite_t;

    sprite_t sprite;

    modport logic_mp (
        output  sprite
    );

    modport display_mp (
        input  sprite
    );

endinterface : sprite_if
