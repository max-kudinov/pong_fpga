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

    sprite_t player_w;
    sprite_t enemy_w;
    sprite_t ball_w;

    sprite_t player_r;
    sprite_t enemy_r;
    sprite_t ball_r;

    localparam [`Y_POS_W - 1:0] DOWN_LIMIT    = `SCREEN_V_RES - (`SCREEN_BORDER + `PADDLE_HEIGHT);
    localparam [`Y_POS_W - 1:0] PADDLE_CENTER = `PADDLE_HEIGHT / 2;
    localparam sprite_t player_center = '{0, `Y_POS_W' (`SCREEN_V_RES / 2 - 32'(PADDLE_CENTER)), 0, 0};

    initial begin
        player_r = player_center;
    end

    logic                   update_enemy;
    logic                   update_player;

    logic [`Y_POS_W - 1:0]  enemy_center;

    logic [`BALL_SPEED_W - 1:0] ball_speed_x;
    logic [`BALL_SPEED_W - 1:0] ball_speed_y;

    logic [`BALL_SPEED_W - 1:0] ball_speed_x_w;
    logic [`BALL_SPEED_W - 1:0] ball_speed_y_w;

    logic [`RND_NUM_W - 1:0] rnd_num;

    logic                    key_up;
    logic                    key_down;

    strobe_gen #(.STROBE_FREQ_HZ(`PC_SPEED)) i_pc_strobe_gen
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

    random #(.TAPS ('h110)) i_random
    (
        .clk_i     ( clk_i   ),
        .rst_i     ( rst_i   ),
        .rnd_num_o ( rnd_num )
    );

    logic [`X_POS_W-1:0] player_tops    [3];
    logic [`X_POS_W-1:0] enemy_tops     [3];
    logic [`X_POS_W-1:0] player_bottoms [3];
    logic [`X_POS_W-1:0] enemy_bottoms  [3];

    logic [2:0] player_colls;
    logic [2:0] enemy_colls;

    // ' symbol is needed to cast packed array to unpacked
    assign player_tops    = '{ player_r.y_pos, player_r.y_pos, player_w.bottom - 1'b1 };
    assign player_bottoms = '{ player_w.bottom, player_r.y_pos + 1'b1, player_w.bottom };
    assign enemy_tops     = '{ enemy_r.y_pos, enemy_r.y_pos, enemy_w.bottom - 1'b1 };
    assign enemy_bottoms  = '{ enemy_w.bottom, enemy_r.y_pos + 1'b1, enemy_w.bottom };

    genvar i;
    generate
        for (i = 0; i < 3; i++) begin : collision_player
            sprite_collision i_player_collision (
                .clk_i          ( clk_i              ),
                .rst_i          ( rst_i              ),
                .rect1_left_i   ( player_r.x_pos     ),
                .rect1_right_i  ( player_w.right     ),
                .rect1_top_i    ( player_tops    [i] ),
                .rect1_bottom_i ( player_bottoms [i] ),
                .rect2_left_i   ( ball_r.x_pos       ),
                .rect2_right_i  ( ball_w.right       ),
                .rect2_top_i    ( ball_r.y_pos       ),
                .rect2_bottom_i ( ball_w.bottom      ),
                .collision_o    ( player_colls   [i] )
            );
        end

        for (i = 0; i < 3; i++) begin : collision_enemy
            sprite_collision i_enemy_collision (
                .clk_i          ( clk_i             ),
                .rst_i          ( rst_i             ),
                .rect1_left_i   ( enemy_r.x_pos     ),
                .rect1_right_i  ( enemy_w.right     ),
                .rect1_top_i    ( enemy_tops    [i] ),
                .rect1_bottom_i ( enemy_bottoms [i] ),
                .rect2_left_i   ( ball_r.x_pos      ),
                .rect2_right_i  ( ball_w.right      ),
                .rect2_top_i    ( ball_r.y_pos      ),
                .rect2_bottom_i ( ball_w.bottom     ),
                .collision_o    ( enemy_colls   [i] )
            );
        end
    endgenerate

    assign key_up   = keys_i[0];
    assign key_down = keys_i[1];

    always_comb begin
        // Calculate new player paddle coordinates
        player_w.x_pos = `X_POS_W' (`SCREEN_H_RES - 20); 
        player_w.y_pos = player_r.y_pos;

        // Move down
        if (key_down && (player_r.y_pos < DOWN_LIMIT))
            player_w.y_pos = player_r.y_pos + 1'b1;

        // Move up
        if (key_up && (player_r.y_pos > `SCREEN_BORDER))
            player_w.y_pos = player_r.y_pos - 1'b1;
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            enemy_center <= '0;
        else
            enemy_center <= enemy_r.y_pos + PADDLE_CENTER;

    always_comb begin
        // Calculate new computer paddle coordinates
        enemy_w.x_pos = `X_POS_W' (20); 
        enemy_w.y_pos = enemy_r.y_pos;

        if ((enemy_center > ball_r.y_pos) && (enemy_r.y_pos > `SCREEN_BORDER))
            enemy_w.y_pos = enemy_r.y_pos - 1'b1;

        if ((enemy_center < ball_r.y_pos) && (enemy_r.y_pos < DOWN_LIMIT))
            enemy_w.y_pos = enemy_r.y_pos + 1'b1;
    end

    always_comb begin
        // Calculate new ball coordinates
        if (ball_speed_x[`BALL_SPEED_W-1])
            ball_w.x_pos = ball_r.x_pos - `X_POS_W' (ball_speed_x[3:0]);
        else
            ball_w.x_pos = ball_r.x_pos + `X_POS_W' (ball_speed_x[3:0]);

        if (ball_speed_y[`BALL_SPEED_W-1])
            ball_w.y_pos = ball_r.y_pos - `Y_POS_W' (ball_speed_y[3:0]);
        else
            ball_w.y_pos = ball_r.y_pos + `Y_POS_W' (ball_speed_y[3:0]);

        if ((ball_r.x_pos > `SCREEN_H_RES) || (ball_r.x_pos < `SCREEN_BORDER)) begin
            ball_w.x_pos = `SCREEN_H_RES / 2;
            ball_w.y_pos = `SCREEN_V_RES / 2;
        end
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

        if ((ball_r.x_pos > `SCREEN_H_RES) || (ball_r.x_pos < `SCREEN_BORDER)) begin
            ball_speed_x_w = { rnd_num[4], 2'b01, rnd_num[7:6] };
            ball_speed_y_w = { rnd_num[5], 3'b000, rnd_num[8]  };
        end

        if (ball_r.y_pos < `SCREEN_BORDER)
            ball_speed_y_w[`BALL_SPEED_W-1] = 1'b0;

        if (ball_r.y_pos + `SCREEN_BORDER > `SCREEN_V_RES)
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

    always_ff @(posedge clk_i)
        if (rst_i) begin
            player_r <= player_center;
            enemy_r  <= '0;
            ball_r   <= '0;
        end else begin
            if (update_player)
                player_r <= player_w;

            if (update_enemy)
                enemy_r  <= enemy_w;

            if (new_frame_i)
                ball_r   <= ball_w;
        end

    always_comb begin
        player_w.right  = player_r.x_pos + `PADDLE_WIDTH;
        player_w.bottom = player_r.y_pos + `PADDLE_HEIGHT;

        enemy_w.right   =  enemy_r.x_pos + `PADDLE_WIDTH;
        enemy_w.bottom  =  enemy_r.y_pos + `PADDLE_HEIGHT;

        ball_w.right    =  ball_r.x_pos + `BALL_SIDE;
        ball_w.bottom   =  ball_r.y_pos + `BALL_SIDE;

        player_x_o      = player_r.x_pos;
        player_y_o      = player_r.y_pos;

        enemy_x_o       = enemy_r.x_pos;
        enemy_y_o       = enemy_r.y_pos;

        ball_x_o        = ball_r.x_pos;
        ball_y_o        = ball_r.y_pos;
    end

endmodule
