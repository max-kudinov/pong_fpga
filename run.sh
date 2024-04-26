/home/mkudinov/intelFPGA_lite/21.1/quartus/bin/quartus_sh --flow compile game_top &&
/home/mkudinov/intelFPGA_lite/21.1/quartus/bin/quartus_pgm -c USB-Blaster --mode=jtag -o "p;output_files/game_top.sof"
