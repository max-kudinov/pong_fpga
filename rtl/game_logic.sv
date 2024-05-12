`include "board_pkg.svh"
`include "vga_pkg.svh"
`include "sprite_pkg.svh"
`include "lfsr_pkg.svh"
`include "score_pkg.svh"

module game_logic
    import sprite_pkg::*,
           board_pkg::KEYS_W,
           board_pkg::LEDS_W,
           vga_pkg::X_POS_W,
           vga_pkg::Y_POS_W,
           vga_pkg::SCREEN_H_RES,
           vga_pkg::SCREEN_V_RES,
           vga_pkg::BOARD_CLK_MHZ,
           lfsr_pkg::RND_NUM_W,
           score_pkg::M_SCORE_W;
(
    input  logic              clk_i,
    input  logic              rst_i,
    input  logic [KEYS_W-1:0] keys_i,
    input  logic              new_frame_i,
    output logic [LEDS_W-1:0] leds_o,

    sprite_if.logic_mp        sprites_o [N_SPRITES],
    score_if.control_mp       score_o
);

    // _Verilator doesn't like assignment to different struct fields
    // in different always blocks

    // verilator lint_off UNOPTFLAT
    sprite_t                  player_w;
    sprite_t                  enemy_w;
    sprite_t                  ball_w;
    // verilator lint_on UNOPTFLAT

    sprite_t                  player_r;
    sprite_t                  enemy_r;
    sprite_t                  ball_r;

    logic                     key_up;
    logic                     key_down;

    logic                     update_enemy;
    logic                     update_player;

    logic                     game_en;
    logic                     game_en_prev;

    logic    [ M_SCORE_W-1:0] player_score_w;
    logic    [ M_SCORE_W-1:0] enemy_score_w;
    logic    [ M_SCORE_W-1:0] player_score_r;
    logic    [ M_SCORE_W-1:0] enemy_score_r;

    logic    [   SPEED_W-1:0] ball_speed_x;
    logic    [   SPEED_W-1:0] ball_speed_y;
    logic    [   SPEED_W-1:0] ball_speed_x_w;
    logic    [   SPEED_W-1:0] ball_speed_y_w;

    logic    [   Y_POS_W-1:0] enemy_center;

    logic    [ RND_NUM_W-1:0] rnd_num;

    logic    [N_HITBOXES-1:0] player_colls;
    logic    [N_HITBOXES-1:0] enemy_colls;

    sprite_t [N_HITBOXES-1:0] p_hitboxes;
    sprite_t [N_HITBOXES-1:0] e_hitboxes;

    sprite_if                p_hit [N_SPRITES] ();
    sprite_if                e_hit [N_SPRITES] ();
    sprite_if                b_hit             ();

    always_comb begin
        p_hitboxes           = { N_SPRITES { player_r } };
        e_hitboxes           = { N_SPRITES { enemy_r  } };

        b_hit.sprite         = ball_r;

        p_hitboxes[2].y_pos  = player_r.bottom - 1'b1;
        e_hitboxes[2].y_pos  = enemy_r.bottom - 1'b1;

        p_hitboxes[1].bottom = player_r.y_pos + 1'b1;
        e_hitboxes[1].bottom = enemy_r.y_pos + 1'b1;
    end

    genvar i;
    generate
        for (i = 0; i < N_HITBOXES; i++) begin : collision_player
            assign p_hit[i].sprite = p_hitboxes[i];

            sprite_collision i_player_collision (
                .clk_i          ( clk_i            ),
                .rst_i          ( rst_i            ),
                .rect_1_i       ( p_hit        [i] ),
                .rect_2_i       ( b_hit            ),
                .collision_o    ( player_colls [i] )
            );
        end

        for (i = 0; i < N_HITBOXES; i++) begin : collision_enemy
            assign e_hit[i].sprite = e_hitboxes[i];

            sprite_collision i_enemy_collision (
                .clk_i          ( clk_i           ),
                .rst_i          ( rst_i           ),
                .rect_1_i       ( e_hit       [i] ),
                .rect_2_i       ( b_hit           ),
                .collision_o    ( enemy_colls [i] )
            );
        end
    endgenerate

    assign key_up   = keys_i[1];
    assign key_down = keys_i[0];

    assign leds_o = keys_i[1:0];

    // Calculate new player paddle coordinates
    always_comb begin
        player_w.x_pos = X_POS_W' (SCREEN_H_RES - PADDLE_PADDING); 
        player_w.y_pos = player_r.y_pos;

        // Move down
        if (key_down && (player_r.y_pos < DOWN_LIMIT))
            player_w.y_pos = player_w.y_pos + 1'b1;

        // Move up
        if (key_up && (player_r.y_pos > SCREEN_BORDER))
            player_w.y_pos = player_w.y_pos - 1'b1;
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            enemy_center <= '0;
        else
            enemy_center <= enemy_r.y_pos + PADDLE_CENTER;

    // Calculate new enemy paddle coordinates
    always_comb begin
        enemy_w.x_pos = X_POS_W' (PADDLE_PADDING); 
        enemy_w.y_pos = enemy_r.y_pos;

        if ((enemy_center > ball_r.y_pos) && (enemy_r.y_pos > SCREEN_BORDER))
            enemy_w.y_pos = enemy_r.y_pos - 1'b1;

        if ((enemy_center < ball_r.y_pos) && (enemy_r.y_pos < DOWN_LIMIT))
            enemy_w.y_pos = enemy_r.y_pos + 1'b1;
    end

    // Calculate new ball coordinates
    always_comb begin
        if (ball_speed_x[SPEED_W-1])
            ball_w.x_pos = ball_r.x_pos - X_POS_W' (ball_speed_x[SPEED_W-2:0]);
        else
            ball_w.x_pos = ball_r.x_pos + X_POS_W' (ball_speed_x[SPEED_W-2:0]);

        if (ball_speed_y[SPEED_W-1])
            ball_w.y_pos = ball_r.y_pos - Y_POS_W' (ball_speed_y[SPEED_W-2:0]);
        else
            ball_w.y_pos = ball_r.y_pos + Y_POS_W' (ball_speed_y[SPEED_W-2:0]);

        if ((ball_r.x_pos > SCREEN_H_RES - SCREEN_BORDER) || (ball_r.x_pos < SCREEN_BORDER)) begin
            ball_w.x_pos = X_POS_W' (SCREEN_H_RES / 2);
            ball_w.y_pos = Y_POS_W' (SCREEN_V_RES / 2);
        end
    end

    strobe_gen #(
        .BOARD_CLK_MHZ  ( BOARD_CLK_MHZ ),
        .STROBE_FREQ_HZ ( PLAYER_SPEED  )
    ) i_player_strobe_gen (
        .clk_i          ( clk_i         ),
        .rst_i          ( rst_i         ),
        .strobe         ( update_player )
    );

    strobe_gen #(
        .BOARD_CLK_MHZ  ( BOARD_CLK_MHZ ),
        .STROBE_FREQ_HZ ( ENEMY_SPEED   )
    ) i_enemy_strobe_gen (
        .clk_i          ( clk_i         ),
        .rst_i          ( rst_i         ),
        .strobe         ( update_enemy  )
    );

    assign player_w.right  = player_w.x_pos + X_POS_W' (PADDLE_WIDTH);
    assign player_w.bottom = player_w.y_pos + Y_POS_W' (PADDLE_HEIGHT);

    assign enemy_w.right   = enemy_w.x_pos + X_POS_W' (PADDLE_WIDTH);
    assign enemy_w.bottom  = enemy_w.y_pos + Y_POS_W' (PADDLE_HEIGHT);

    assign ball_w.right    = ball_w.x_pos + X_POS_W' (BALL_SIDE);
    assign ball_w.bottom   = ball_w.y_pos + Y_POS_W' (BALL_SIDE);

    // Initialize FPGA register on upload
    initial begin
        player_r = INIT_ST_P;
        enemy_r  = INIT_ST_P;
        ball_r   = INIT_ST_B;
    end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            player_r     <= INIT_ST_P;
            enemy_r      <= INIT_ST_P;
            ball_r       <= INIT_ST_B;
        end else begin
            if (~game_en)
                ball_r   <= INIT_ST_B;
            else begin
            if (update_player)
                player_r <= player_w;

            if (update_enemy)
                enemy_r  <= enemy_w;

            if (new_frame_i)
                ball_r   <= ball_w;
            end
        end

    assign sprites_o[0].sprite = player_r;
    assign sprites_o[1].sprite = enemy_r;
    assign sprites_o[2].sprite = ball_r;

    lfsr i_lfsr (
        .clk_i     ( clk_i   ),
        .rst_i     ( rst_i   ),
        .rnd_num_o ( rnd_num )
    );

    // Calculate new ball speed
    always_comb begin
        ball_speed_x_w = ball_speed_x;
        ball_speed_y_w = ball_speed_y;

        if (player_colls[0]) begin
            ball_speed_x_w[SPEED_W-1]   = 1'b1;
            ball_speed_x_w[SPEED_W-2:1] = DEFLECT_SPEED_X;
            ball_speed_x_w[0]            = rnd_num[0];

            ball_speed_y_w[SPEED_W-2:0] = DEFLECT_SPEED_Y;
            ball_speed_y_w[1]            = rnd_num[1];
        end

        if (enemy_colls[0]) begin
            ball_speed_x_w[SPEED_W-1]   = 1'b0;
            ball_speed_x_w[SPEED_W-2:1] = DEFLECT_SPEED_X;
            ball_speed_x_w[0]            = rnd_num[2];

            ball_speed_y_w[SPEED_W-2:0] = DEFLECT_SPEED_Y;
            ball_speed_y_w[1]            = rnd_num[3];
        end

        if ((key_up && player_colls[1]) || enemy_colls[1]) begin
            ball_speed_y_w[SPEED_W-1]   = 1'b1;
            ball_speed_y_w[SPEED_W-2:0] = SIDE_HIT_SPEED_Y;
        end

        if ((key_down && player_colls[2]) || enemy_colls[2]) begin
            ball_speed_y_w[SPEED_W-1]   = 1'b0;
            ball_speed_y_w[SPEED_W-2:0] = SIDE_HIT_SPEED_Y;
        end

        if ((ball_r.x_pos > SCREEN_H_RES - SCREEN_BORDER) || (ball_r.x_pos < SCREEN_BORDER)) begin
            ball_speed_x_w = { rnd_num[4], 2'b01,  rnd_num[7:6] };
            ball_speed_y_w = { rnd_num[5], 3'b000, rnd_num[8]   };
        end

        if (ball_r.y_pos < SCREEN_BORDER)
            ball_speed_y_w[SPEED_W-1] = 1'b0;

        if (ball_r.y_pos + SCREEN_BORDER > SCREEN_V_RES)
            ball_speed_y_w[SPEED_W-1] = 1'b1;
    end

    // Initialize FPGA register on upload
    initial begin
        ball_speed_x = INIT_SPEED_B;
        ball_speed_y = '0;
    end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            ball_speed_x <= INIT_SPEED_B;
            ball_speed_y <= '0;
        end else begin
            ball_speed_x <= ball_speed_x_w;
            ball_speed_y <= ball_speed_y_w;
        end

    game_fsm i_game_fsm (
        .clk_i      ( clk_i          ),
        .rst_i      ( rst_i          ),
        .game_rst_i ( keys_i [2]     ),
        .p_score_i  ( player_score_r ),
        .e_score_i  ( enemy_score_r  ),
        .game_en_o  ( game_en        )
    );

    always_ff @(posedge clk_i)
        if (rst_i) begin
            player_score_r <= '0;
            enemy_score_r  <= '0;
        end else if (game_en & ~game_en_prev) begin
            player_score_r <= '0;
            enemy_score_r  <= '0;
        end else if (new_frame_i) begin
            player_score_r <= player_score_w;
            enemy_score_r  <= enemy_score_w;
        end

    always_comb begin
        player_score_w = player_score_r;
        enemy_score_w  = enemy_score_r;

        if (ball_r.x_pos > SCREEN_H_RES - SCREEN_BORDER)
            enemy_score_w = enemy_score_r + 1'b1;
            
        if (ball_r.x_pos < SCREEN_BORDER)
            player_score_w = player_score_r + 1'b1;
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            game_en_prev <= '0;
        else
            game_en_prev <= game_en;

    game_score i_game_score (
        .clk_i          ( clk_i          ),
        .rst_i          ( rst_i          ),
        .player_score_i ( player_score_r ),
        .enemy_score_i  ( enemy_score_r  ),
        .score_o        ( score_o        )
    );

endmodule
