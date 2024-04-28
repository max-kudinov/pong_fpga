module random 
#(
    parameter WIDTH = 16
)
(
    input  logic               clk_i,
    input  logic               rst_i,
    output logic [WIDTH - 1:0] rnd_num_o
);

    always_ff @(posedge clk_i)
        if (rst_i)
            rnd_num_o <= WIDTH' (69420); // random seed
        else
            rnd_num_o <= { rnd_num_o[WIDTH - 2:0],
            rnd_num_o[WIDTH - 1] ^ rnd_num_o[WIDTH / 4] ^ rnd_num_o[WIDTH / 2] };

endmodule
