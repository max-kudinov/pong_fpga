#!/bin/bash

source ~/oss-cad-suite/environment

if ! yosys -m slang -p "read_slang --single-unit --libraries-inherit-macros -DPRIMER20K -DGOWIN \
                   -Irtl/include rtl/* rtl/DVI/* rtl/blackboxes/*; \
                   synth_gowin -top primer20k_board_top -json design.json"
then
    exit 1
fi

if ! nextpnr-himbaechel --json design.json           \
                   --write placed.json          \
                   --device GW2A-LV18PG256C8/I7 \
                   --vopt family=GW2A-18        \
                   --vopt cst=yosys/pins.cst     \
                   --sdc yosys/constrainsts.sdc
then
    exit 1
fi

if ! gowin_pack -d GW2A-18 -o pack.fs placed.json
then
    exit 1
fi

if ! openFPGALoader -b tangprimer20k pack.fs
then
    exit 1
fi
