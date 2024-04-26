~/intelFPGA_lite/21.1/quartus/bin/quartus_sh --flow compile quartus/pong_fpga &&
~/intelFPGA_lite/21.1/quartus/bin/quartus_pgm -c USB-Blaster --mode=jtag -o "p;quartus/output_files/pong_fpga.sof"
