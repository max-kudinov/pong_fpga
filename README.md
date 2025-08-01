# This is Pong on FPGA

![pong](img/pong.jpg)

Pong game written in SystemVerilog for FPGA board. After I wrote Pong in C I
wanted to go deeper into hardware, so digital logic was the next step.

## How to run
I've used Zeowaa board with Cyclone IV, because it's the only board I have at
the moment. So the run script uses Quartus. If you want to use the script, make
sure that the Quartus directory is at `~/intelFPGA_lite`

If you use any other board, it is pretty easy to change board specific module
and use your board with preferred toolchain.

## Update
I've got another board (Primer 20k) with DVI interface. Now there're two
scripts: `zeowaa_synth.sh` for the old Altera board and `primer20k_synth.sh`
for the new Gowin board.

Also display interface became generic and configured according to the used board.
Score digits scaling became much more cleaner, achives better Fmax and uses
less resources.

![pong_primer20k](img/primer20k_pong.jpg)
