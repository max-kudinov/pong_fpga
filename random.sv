`include "config.svh"

module random (
    input  logic                    clk_i,
    input  logic                    rst_i,
    output logic [`RND_NUM_W - 1:0] rnd_num_o
);

    always_ff @(posedge clk_i)
        if (rst_i)
            rnd_num_o <= `RND_NUM_W' (`RND_SEED); // random seed
        else
            rnd_num_o <= { rnd_num_o[`RND_NUM_W - 2:0],
            rnd_num_o[`RND_NUM_W - 1] ^ rnd_num_o[`RND_NUM_W / 4] ^ rnd_num_o[`RND_NUM_W / 2] };

endmodule
