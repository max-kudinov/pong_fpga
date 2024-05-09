`include "config.svh"

module game_logic (
    input  logic                  clk_i,
    input  logic                  rst_i,
    input  logic [`KEYS_W - 1:0]  keys_i,

    input  logic                  new_frame_i,

    output logic [`X_POS_W - 1:0] player_x_o,
    output logic [`Y_POS_W - 1:0] player_y_o,

    output logic [`X_POS_W - 1:0] enemy_x_o,
    output logic [`Y_POS_W - 1:0] enemy_y_o,

    output logic [`X_POS_W - 1:0] ball_x_o,
    output logic [`Y_POS_W - 1:0] ball_y_o
);

    sprite_t                  player;
    sprite_t                  enemy;
    sprite_t                  ball;

    logic                     key_up;
    logic                     key_down;

    logic [`X_POS_W-1:0]      p_hit_top [3];
    logic [`X_POS_W-1:0]      e_hit_top [3];
    logic [`X_POS_W-1:0]      p_hit_bot [3];
    logic [`X_POS_W-1:0]      e_hit_bot [3];

    logic [2:0]               player_colls;
    logic [2:0]               enemy_colls;

    logic [`BALL_SPEED_W-1:0] ball_speed_x;
    logic [`BALL_SPEED_W-1:0] ball_speed_y;
    logic [`BALL_SPEED_W-1:0] ball_speed_x_w;
    logic [`BALL_SPEED_W-1:0] ball_speed_y_w;

    logic                     update_enemy;
    logic                     update_player;

    logic [`Y_POS_W-1:0]      enemy_center;

    logic [`RND_NUM_W-1:0]    rnd_num;


    strobe_gen #(.STROBE_FREQ_HZ(`ENEMY_SPEED)) i_enemy_strobe_gen
    (
        .clk_i  ( clk_i  ),
        .rst_i  ( rst_i  ),
        .strobe ( update_enemy )
    );

    strobe_gen #(.STROBE_FREQ_HZ(`PLAYER_SPEED)) i_player_strobe_gen
    (
        .clk_i  ( clk_i         ),
        .rst_i  ( rst_i         ),
        .strobe ( update_player )
    );

    random #(.TAPS (`TAPS)) i_random
    (
        .clk_i     ( clk_i   ),
        .rst_i     ( rst_i   ),
        .rnd_num_o ( rnd_num )
    );

    // ' symbol is needed to cast packed array to unpacked
    assign p_hit_top = '{ player_y_o,    player_y_o,        player.bottom - 1'b1 };
    assign p_hit_bot = '{ player.bottom, player_y_o + 1'b1, player.bottom };
    assign e_hit_top = '{ enemy_y_o,     enemy_y_o,         enemy.bottom - 1'b1 };
    assign e_hit_bot = '{ enemy.bottom,  enemy_y_o + 1'b1,  enemy.bottom };

    assign player.right  = player_x_o + `PADDLE_WIDTH;
    assign player.bottom = player_y_o + `PADDLE_HEIGHT;

    assign enemy.right   =  enemy_x_o + `PADDLE_WIDTH;
    assign enemy.bottom  =  enemy_y_o + `PADDLE_HEIGHT;

    assign ball.right    =  ball_x_o + `BALL_SIDE;
    assign ball.bottom   =  ball_y_o + `BALL_SIDE;

    genvar i;
    generate
        for (i = 0; i < 3; i++) begin : collision_player
            sprite_collision i_player_collision (
                .clk_i          ( clk_i            ),
                .rst_i          ( rst_i            ),
                .rect1_left_i   ( player_x_o       ),
                .rect1_right_i  ( player.right     ),
                .rect1_top_i    ( p_hit_top    [i] ),
                .rect1_bottom_i ( p_hit_bot    [i] ),
                .rect2_left_i   ( ball_x_o         ),
                .rect2_right_i  ( ball.right       ),
                .rect2_top_i    ( ball_y_o         ),
                .rect2_bottom_i ( ball.bottom      ),
                .collision_o    ( player_colls [i] )
            );
        end

        for (i = 0; i < 3; i++) begin : collision_enemy
            sprite_collision i_enemy_collision (
                .clk_i          ( clk_i           ),
                .rst_i          ( rst_i           ),
                .rect1_left_i   ( enemy_x_o       ),
                .rect1_right_i  ( enemy.right     ),
                .rect1_top_i    ( e_hit_top   [i] ),
                .rect1_bottom_i ( e_hit_bot   [i] ),
                .rect2_left_i   ( ball_x_o        ),
                .rect2_right_i  ( ball.right      ),
                .rect2_top_i    ( ball_y_o        ),
                .rect2_bottom_i ( ball.bottom     ),
                .collision_o    ( enemy_colls [i] )
            );
        end
    endgenerate

    assign key_up   = keys_i[0];
    assign key_down = keys_i[1];

    always_comb begin
        // Calculate new player paddle coordinates
        player.x_pos = `X_POS_W' (`SCREEN_H_RES - 20); 
        player.y_pos = player_y_o;

        // Move down
        if (key_down && (player_y_o < DOWN_LIMIT))
            player.y_pos = player_y_o + 1'b1;

        // Move up
        if (key_up && (player_y_o > `SCREEN_BORDER))
            player.y_pos = player_y_o - 1'b1;
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            enemy_center <= '0;
        else
            enemy_center <= enemy_y_o + PADDLE_CENTER;

    always_comb begin
        // Calculate new enemy paddle coordinates
        enemy.x_pos = `X_POS_W' (20); 
        enemy.y_pos = enemy_y_o;

        if ((enemy_center > ball_y_o) && (enemy_y_o > `SCREEN_BORDER))
            enemy.y_pos = enemy_y_o - 1'b1;

        if ((enemy_center < ball_y_o) && (enemy_y_o < DOWN_LIMIT))
            enemy.y_pos = enemy_y_o + 1'b1;
    end

    always_comb begin
        // Calculate new ball coordinates
        if (ball_speed_x[`BALL_SPEED_W-1])
            ball.x_pos = ball_x_o - `X_POS_W' (ball_speed_x[3:0]);
        else
            ball.x_pos = ball_x_o + `X_POS_W' (ball_speed_x[3:0]);

        if (ball_speed_y[`BALL_SPEED_W-1])
            ball.y_pos = ball_y_o - `Y_POS_W' (ball_speed_y[3:0]);
        else
            ball.y_pos = ball_y_o + `Y_POS_W' (ball_speed_y[3:0]);

        if ((ball_x_o > `SCREEN_H_RES) || (ball_x_o < `SCREEN_BORDER)) begin
            ball.x_pos = `SCREEN_H_RES / 2;
            ball.y_pos = `SCREEN_V_RES / 2;
        end
    end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            player_x_o <= '0;
            player_y_o <= v_center;

            enemy_x_o  <= '0;
            enemy_y_o  <= v_center;

            ball_x_o   <= '0;
            ball_y_o   <= '0;
        end else begin
            if (update_player) begin
                player_x_o <= player.x_pos;
                player_y_o <= player.y_pos;
            end

            if (update_enemy) begin
                enemy_x_o  <= enemy.x_pos;
                enemy_y_o  <= enemy.y_pos;
            end

            if (new_frame_i) begin
                ball_x_o   <= ball.x_pos;
                ball_y_o   <= ball.y_pos;
            end
        end

    // Initialize FPGA registers on upload
    initial begin
        player_y_o = v_center;
    end

    always_comb begin
        // Calculate new ball speed
        ball_speed_x_w = ball_speed_x;
        ball_speed_y_w = ball_speed_y;

        if (player_colls[0]) begin
            ball_speed_x_w = {4'b1100, rnd_num[0]};
            ball_speed_y_w[3:0] = {2'b00, rnd_num[1], 1'b1};
        end

        if (enemy_colls[0]) begin
            ball_speed_x_w = {4'b0100, rnd_num[2]};
            ball_speed_y_w[3:0] = {2'b00, rnd_num[3], 1'b1};
        end

        if ((key_up && player_colls[1]) || enemy_colls[1]) begin
            ball_speed_y_w = 5'b10101; 
        end

        if ((key_down && player_colls[2]) || enemy_colls[2]) begin
            ball_speed_y_w = 5'b00101; 
        end

        if ((ball_x_o > `SCREEN_H_RES) || (ball_x_o < `SCREEN_BORDER)) begin
            ball_speed_x_w = { rnd_num[4], 2'b01, rnd_num[7:6] };
            ball_speed_y_w = { rnd_num[5], 3'b000, rnd_num[8]  };
        end

        if (ball_y_o < `SCREEN_BORDER)
            ball_speed_y_w[`BALL_SPEED_W-1] = 1'b0;

        if (ball_y_o + `SCREEN_BORDER > `SCREEN_V_RES)
            ball_speed_y_w[`BALL_SPEED_W-1] = 1'b1;
    end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            ball_speed_x <= '0;
            ball_speed_y <= '0;
        end else begin
            ball_speed_x <= ball_speed_x_w;
            ball_speed_y <= ball_speed_y_w;
        end

endmodule
