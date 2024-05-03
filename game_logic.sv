`include "config.svh"

module game_logic (
    input  logic                  clk_i,
    input  logic                  rst_i,

    input  logic [`KEYS_W - 1:0]  keys_i,
    input  logic                  new_frame_i,

    output logic [`X_POS_W - 1:0] player_paddle_x_o,
    output logic [`Y_POS_W - 1:0] player_paddle_y_o,

    output logic [`X_POS_W - 1:0] pc_paddle_x_o,
    output logic [`Y_POS_W - 1:0] pc_paddle_y_o,

    output logic [`X_POS_W - 1:0] ball_x_o,
    output logic [`Y_POS_W - 1:0] ball_y_o

);
    logic [`Y_POS_W - 1:0]  player_paddle_y_w;
    logic [`Y_POS_W - 1:0]  pc_paddle_y_w;
    logic [`Y_POS_W - 1:0]  pc_paddle_center;

    logic [`X_POS_W - 1:0]  ball_x_w;
    logic [`Y_POS_W - 1:0]  ball_y_w;

    logic [`BALL_SPEED_W - 1:0] ball_speed_x;
    logic [`BALL_SPEED_W - 1:0] ball_speed_y;

    logic [`BALL_SPEED_W - 1:0] ball_speed_x_d;
    logic [`BALL_SPEED_W - 1:0] ball_speed_y_d;

    logic [`Y_POS_W - 1:0] pc_speed_y_d;

    logic [`RND_NUM_W - 1:0] rnd_num;

    logic                    key_up;
    logic                    key_down;

    random i_random (
        .clk_i     ( clk_i   ),
        .rst_i     ( rst_i   ),
        .rnd_num_o ( rnd_num )
    );

    localparam [`Y_POS_W - 1:0] DOWN_LIMIT    = `SCREEN_V_RES - (`SCREEN_BORDER + `PADDLE_HEIGHT);
    localparam [`Y_POS_W - 1:0] PADDLE_CENTER = `PADDLE_HEIGHT / 2;

    assign key_up   = keys_i[0];
    assign key_down = keys_i[1];

    always_comb begin
        // Calculate new player paddle coordinates
        player_paddle_y_w = player_paddle_y_o;

        // Move down
        if (key_down && (player_paddle_y_o < DOWN_LIMIT))
            player_paddle_y_w = player_paddle_y_o + `PLAYER_SPEED;

        // Move up
        if (key_up && (player_paddle_y_o > `SCREEN_BORDER))
            player_paddle_y_w = player_paddle_y_o - `PLAYER_SPEED;
    end

    always_ff @(posedge clk_i)
        if (rst_i) 
            player_paddle_y_o <= `Y_POS_W' (`SCREEN_V_RES / 2);
        else if (new_frame_i) 
            player_paddle_y_o <= player_paddle_y_w;

    assign player_paddle_x_o = `X_POS_W' (`SCREEN_H_RES - 20); 

    always_comb begin
        // Calculate new computer paddle coordinates
        pc_paddle_y_w = pc_paddle_y_o;
        pc_speed_y_d  = '0;
        pc_paddle_center = pc_paddle_y_o + PADDLE_CENTER;


        if ((pc_paddle_center > ball_y_o) && (pc_paddle_y_o > `SCREEN_BORDER)) begin
            pc_speed_y_d  = (pc_paddle_center - ball_y_o) & `Y_POS_W' (3);   
            pc_paddle_y_w = pc_paddle_y_o - pc_speed_y_d;
        end

        if ((pc_paddle_center < ball_y_o) && (pc_paddle_y_o < DOWN_LIMIT)) begin
            pc_speed_y_d  = (ball_y_o - pc_paddle_center) & `Y_POS_W' (3);  
            pc_paddle_y_w = pc_paddle_y_o + pc_speed_y_d;

        end
    end

    always_ff @(posedge clk_i)
        if (rst_i) 
            pc_paddle_y_o <= `Y_POS_W' (`SCREEN_V_RES / 2);
        else if (new_frame_i)
            pc_paddle_y_o <= pc_paddle_y_w;
        
    assign pc_paddle_x_o = `X_POS_W' (20); 

    always_comb begin
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
        if ((player_paddle_x_o < ball_x_w          + `BALL_SIDE) &&
            (ball_y_w          < player_paddle_y_w + `PADDLE_HEIGHT) &&
            (player_paddle_y_w < ball_y_w          + `SCREEN_BORDER))
            ball_speed_x_d[`BALL_SPEED_W - 1] = 1'b1;

        // Check collision with computer paddle
        if ((ball_x_w      < pc_paddle_x_o + `BALL_SIDE) &&
            (ball_y_w      < pc_paddle_y_w + `PADDLE_HEIGHT) &&
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
            ball_x_o          <= `X_POS_W' (`SCREEN_H_RES / 2);
            ball_y_o          <= `Y_POS_W' (`SCREEN_V_RES / 2);
        end else if (new_frame_i) begin
            ball_x_o          <= ball_x_w;
            ball_y_o          <= ball_y_w;
        end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            ball_speed_x <= `BALL_SPEED_W'd1;
            ball_speed_y <= `BALL_SPEED_W'd1;
        end else if (new_frame_i) begin
            ball_speed_x <= ball_speed_x_d;
            ball_speed_y <= ball_speed_y_d;
        end

endmodule
