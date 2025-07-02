
interface display_if;

    `ifdef PRIMER20K
        logic [2:0] tmds_data_p;
        logic [2:0] tmds_data_n;
        logic       tmds_clk_p;
        logic       tmds_clk_n;
        logic       serial_clk;
    `elsif ZEOWAA
        logic       red;
        logic       green;
        logic       blue;
        logic       vsync;
        logic       hsync;
    `else
        initial $error("Wrong board configuration, either PRIMER20K or ZEOWAA should be defined")
    `endif


endinterface : display_if

