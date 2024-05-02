`include "config.svh"

module game_logic (
    input  logic                  clk_i,
    input  logic                  rst_i,

    input  logic [`KEYS_W - 1:0]  keys_i,

    output logic [`X_POS_W - 1:0] player_paddle_x_o,
    output logic [`Y_POS_W - 1:0] player_paddle_y_o,

    output logic [`X_POS_W - 1:0] pc_paddle_x_o,
    output logic [`Y_POS_W - 1:0] pc_paddle_y_o,

    output logic [`X_POS_W - 1:0] ball_x_o,
    output logic [`Y_POS_W - 1:0] ball_y_o

);
    logic [`X_POS_W - 1:0]  player_paddle_x_w;
    logic [`Y_POS_W - 1:0]  player_paddle_y_w;

    logic [`X_POS_W - 1:0]  pc_paddle_x_w;
    logic [`Y_POS_W - 1:0]  pc_paddle_y_w;

    logic [`X_POS_W - 1:0]  ball_x_w;
    logic [`Y_POS_W - 1:0]  ball_y_w;

    logic [`BALL_SPEED_W - 1:0] ball_speed_x;
    logic [`BALL_SPEED_W - 1:0] ball_speed_y;

    logic [`BALL_SPEED_W - 1:0] ball_speed_x_d;
    logic [`BALL_SPEED_W - 1:0] ball_speed_y_d;

    logic [`RND_NUM_W - 1:0] rnd_num;

    localparam freq_cnt_max = `BOARD_CLK_MHZ * 1_000_000 / 30;
    localparam cnt_w = $clog2(freq_cnt_max + 1);

    random i_random (
        .clk_i     ( clk_i   ),
        .rst_i     ( rst_i   ),
        .rnd_num_o ( rnd_num )
    );

    logic [cnt_w - 1:0] freq_cnt;
    wire update = freq_cnt == freq_cnt_max;

    always_ff @(posedge clk_i)
        if (rst_i)
            freq_cnt <= '0;
        else if (update)
            freq_cnt <= '0;
        else
            freq_cnt <= freq_cnt + 1'b1;

    always_comb begin
        // Calculate new player paddle coordinates
        player_paddle_x_w = `X_POS_W' (`SCREEN_H_RES - 20);
        player_paddle_y_w = player_paddle_y_o;

        if (keys_i[0] && player_paddle_y_o < (`Y_POS_W'(`SCREEN_V_RES) -
            `Y_POS_W'(`SCREEN_BORDER + `PLAYER_PADDLE_HEIGHT)))
            player_paddle_y_w = player_paddle_y_o + `Y_POS_W'(`PLAYER_PADDLE_SPEED);

        if (keys_i[1] && player_paddle_y_o > `Y_POS_W'(`SCREEN_BORDER))
            player_paddle_y_w = player_paddle_y_o - `Y_POS_W'(`PLAYER_PADDLE_SPEED);

        // Calculate new computer paddle coordinates
        pc_paddle_x_w = `X_POS_W' (20);
        pc_paddle_y_w = pc_paddle_y_o;

        if (pc_paddle_y_o + `PC_PADDLE_HEIGHT / 4 > ball_y_o && pc_paddle_y_o > `SCREEN_BORDER)
            pc_paddle_y_w = pc_paddle_y_o - `Y_POS_W' (`PC_PADDLE_SPEED);

        else if (pc_paddle_y_o + `PC_PADDLE_HEIGHT - `SCREEN_BORDER < ball_y_o &&
            pc_paddle_y_o + `PC_PADDLE_HEIGHT < `SCREEN_V_RES - `SCREEN_BORDER)
            pc_paddle_y_w = pc_paddle_y_o + `Y_POS_W' (`PC_PADDLE_SPEED);

        // Calculate new ball coordinates
        ball_x_w = ball_x_o;
        ball_y_w = ball_y_o;

        if (ball_speed_x[`BALL_SPEED_W - 1])
            ball_x_w = ball_x_o - ball_speed_x[`BALL_SPEED_W - 2:0];
        else
            ball_x_w = ball_x_o + ball_speed_x[`BALL_SPEED_W - 2:0];

        if (ball_speed_y[`BALL_SPEED_W - 1])
            ball_y_w = ball_y_o - ball_speed_y[`BALL_SPEED_W - 2:0];
        else
            ball_y_w = ball_y_o + ball_speed_y[`BALL_SPEED_W - 2:0];

        // Calculate new ball speed
        ball_speed_x_d = ball_speed_x;
        ball_speed_y_d = ball_speed_y;

        // Check collision with player paddle
        if ((player_paddle_x_w < ball_x_w          + `BALL_SIDE) &&
            (ball_y_w          < player_paddle_y_w + `PLAYER_PADDLE_HEIGHT) &&
            (player_paddle_y_w < ball_y_w          + `SCREEN_BORDER))
            ball_speed_x_d[`BALL_SPEED_W - 1] = 1'b1;

        // Check collision with computer paddle
        if ((ball_x_w      < pc_paddle_x_w + `BALL_SIDE) &&
            (ball_y_w      < pc_paddle_y_w + `PC_PADDLE_HEIGHT) &&
            (pc_paddle_y_w < ball_y_w      + `SCREEN_BORDER))
            ball_speed_x_d[`BALL_SPEED_W - 1] = 1'b0;

            if ((ball_x_w > `SCREEN_H_RES) || (ball_x_w < 1)) begin
                ball_x_w = `SCREEN_H_RES / 2;
                ball_y_w = `SCREEN_V_RES / 2;

                ball_speed_x_d[7]   =    (rnd_num[`RND_NUM_W - 1]);
                // ball_speed_x_d[6:0] <= 7' (rnd_num[3:2] + 1'b1);
                ball_speed_y_d[7]   =    (rnd_num[0]);
                // ball_speed_y[6:0] <= 7' (rnd_num[1:0]);
            end

            if (ball_y_w < `SCREEN_BORDER)
                ball_speed_y_d[7] = 1'b0;
            if (ball_y_w + `SCREEN_BORDER > `SCREEN_V_RES)
                ball_speed_y_d[7] = 1'b1;

    end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            player_paddle_x_o <= `X_POS_W' (`SCREEN_H_RES - 20); 
            player_paddle_y_o <= `Y_POS_W' (`SCREEN_V_RES / 2);
        end else if (update) begin
            player_paddle_x_o <= player_paddle_x_w;
            player_paddle_y_o <= player_paddle_y_w;
        end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            pc_paddle_x_o     <= `X_POS_W' (20); 
            pc_paddle_y_o     <= `Y_POS_W' (`SCREEN_V_RES / 2);
        end else if (update) begin
            pc_paddle_x_o     <= pc_paddle_x_w;
            pc_paddle_y_o     <= pc_paddle_y_w;
        end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            ball_x_o          <= `X_POS_W' (`SCREEN_H_RES / 2);
            ball_y_o          <= `Y_POS_W' (`SCREEN_V_RES / 2);
        end else if (update) begin
            ball_x_o          <= ball_x_w;
            ball_y_o          <= ball_y_w;
        end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            ball_speed_x <= `BALL_SPEED_W'd3;
            ball_speed_y <= `BALL_SPEED_W'd2;
        end else if (update) begin
            ball_speed_x <= ball_speed_x_d;
            ball_speed_y <= ball_speed_y_d;
        end

endmodule
