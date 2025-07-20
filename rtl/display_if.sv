`include "display_pkg.svh"

interface display_if;
    import display_pkg::RGB_W;

    `ifdef DVI
        logic [2:0]       tmds_data_p;
        logic [2:0]       tmds_data_n;
        logic             tmds_clk_p;
        logic             tmds_clk_n;
        logic             serial_clk;
    `elsif VGA
        logic [RGB_W-1:0] vga_rgb;
        logic             vga_vs;
        logic             vga_hs;
    `else
        initial $error("No video interface defined");
    `endif


endinterface : display_if

