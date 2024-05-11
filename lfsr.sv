`include "lfsr_pkg.svh"

module lfsr
    import lfsr_pkg::*;
(
    input  logic                    clk_i,
    input  logic                    rst_i,
    output logic [RND_NUM_W-1:0]    rnd_num_o
);

    // Initialize fpga register on upload
    initial begin
        rnd_num_o = RND_NUM_W' (RND_SEED); // random seed
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            rnd_num_o <= RND_NUM_W' (RND_SEED); // random seed
        else
            rnd_num_o <= { rnd_num_o[RND_NUM_W - 2:0], ^(rnd_num_o & TAPS) };

endmodule
