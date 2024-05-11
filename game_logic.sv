`include "board_pkg.svh"
`include "vga_pkg.svh"
`include "sprite_pkg.svh"
`include "lfsr_pkg.svh"

module game_logic
    import sprite_pkg::*,
           board_pkg::KEYS_W,
           vga_pkg::X_POS_W,
           vga_pkg::Y_POS_W,
           vga_pkg::SCREEN_H_RES,
           vga_pkg::SCREEN_V_RES,
           vga_pkg::BOARD_CLK_MHZ,
           lfsr_pkg::RND_NUM_W;
(
    input  logic               clk_i,
    input  logic               rst_i,
    input  logic [KEYS_W-1:0]  keys_i,

    input  logic               new_frame_i,

    output logic [X_POS_W-1:0] player_x_o,
    output logic [Y_POS_W-1:0] player_y_o,

    output logic [X_POS_W-1:0] enemy_x_o,
    output logic [Y_POS_W-1:0] enemy_y_o,

    output logic [X_POS_W-1:0] ball_x_o,
    output logic [Y_POS_W-1:0] ball_y_o

);

    assign player_x_o = player_o.x_pos;
    assign player_y_o = player_o.y_pos;

    assign enemy_x_o  = enemy_o.x_pos;
    assign enemy_y_o  = enemy_o.y_pos;

    assign ball_x_o   = ball_o.x_pos;
    assign ball_y_o   = ball_o.y_pos;

    // _Verilator doesn't like assignment to different struct fields
    // in different always blocks

    // verilator lint_off UNOPTFLAT
    sprite_t                  player_w;
    sprite_t                  enemy_w;
    sprite_t                  ball_w;
    // verilator lint_on UNOPTFLAT

    sprite_t                  player_o;
    sprite_t                  enemy_o;
    sprite_t                  ball_o;


    logic                     key_up;
    logic                     key_down;

    logic [2:0]               player_colls;
    logic [2:0]               enemy_colls;

    logic [SPEED_W-1:0]      ball_speed_x;
    logic [SPEED_W-1:0]      ball_speed_y;
    logic [SPEED_W-1:0]      ball_speed_x_w;
    logic [SPEED_W-1:0]      ball_speed_y_w;

    logic                     update_enemy;
    logic                     update_player;

    logic [Y_POS_W-1:0]      enemy_center;

    logic [RND_NUM_W-1:0]    rnd_num;

    sprite_t [2:0]          p_hitboxes;
    sprite_t [2:0]          e_hitboxes;

    sprite_if               p_sprite [3] ();
    sprite_if               e_sprite [3] ();
    sprite_if               b_sprite     ();

    always_comb begin
        p_hitboxes           = { 3 { player_o } };
        e_hitboxes           = { 3 { enemy_o  } };

        b_sprite.sprite      = ball_o;

        p_hitboxes[2].y_pos  = player_o.bottom - 1'b1;
        e_hitboxes[2].y_pos  = enemy_o.bottom - 1'b1;

        p_hitboxes[1].bottom = player_o.y_pos + 1'b1;
        e_hitboxes[1].bottom = enemy_o.y_pos + 1'b1;
    end

    genvar i;
    generate
        for (i = 0; i < 3; i++) begin : collision_player
            assign p_sprite[i].sprite = p_hitboxes[i];

            sprite_collision i_player_collision (
                .clk_i          ( clk_i            ),
                .rst_i          ( rst_i            ),
                .rect_1_i       ( p_sprite     [i] ),
                .rect_2_i       ( b_sprite         ),
                .collision_o    ( player_colls [i] )
            );
        end

        for (i = 0; i < 3; i++) begin : collision_enemy
            assign e_sprite[i].sprite = e_hitboxes[i];

            sprite_collision i_enemy_collision (
                .clk_i          ( clk_i           ),
                .rst_i          ( rst_i           ),
                .rect_1_i       ( e_sprite    [i] ),
                .rect_2_i       ( b_sprite        ),
                .collision_o    ( enemy_colls [i] )
            );
        end
    endgenerate

    assign key_up   = keys_i[1];
    assign key_down = keys_i[0];

    // Calculate new player paddle coordinates
    always_comb begin
        player_w.x_pos = X_POS_W' (SCREEN_H_RES - 20); 
        player_w.y_pos = player_o.y_pos;

        // Move down
        if (key_down && (player_o.y_pos < DOWN_LIMIT))
            player_w.y_pos = player_w.y_pos + 1'b1;

        // Move up
        if (key_up && (player_o.y_pos > SCREEN_BORDER))
            player_w.y_pos = player_w.y_pos - 1'b1;
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            enemy_center <= '0;
        else
            enemy_center <= enemy_o.y_pos + PADDLE_CENTER;

    // Calculate new enemy paddle coordinates
    always_comb begin
        enemy_w.x_pos = X_POS_W' (20); 
        enemy_w.y_pos = enemy_o.y_pos;

        if ((enemy_center > ball_o.y_pos) && (enemy_o.y_pos > SCREEN_BORDER))
            enemy_w.y_pos = enemy_o.y_pos - 1'b1;

        if ((enemy_center < ball_o.y_pos) && (enemy_o.y_pos < DOWN_LIMIT))
            enemy_w.y_pos = enemy_o.y_pos + 1'b1;
    end

    // Calculate new ball coordinates
    always_comb begin
        if (ball_speed_x[SPEED_W-1])
            ball_w.x_pos = ball_o.x_pos - X_POS_W' (ball_speed_x[3:0]);
        else
            ball_w.x_pos = ball_o.x_pos + X_POS_W' (ball_speed_x[3:0]);

        if (ball_speed_y[SPEED_W-1])
            ball_w.y_pos = ball_o.y_pos - Y_POS_W' (ball_speed_y[3:0]);
        else
            ball_w.y_pos = ball_o.y_pos + Y_POS_W' (ball_speed_y[3:0]);

        if ((ball_o.x_pos > SCREEN_H_RES) || (ball_o.x_pos < SCREEN_BORDER)) begin
            ball_w.x_pos = SCREEN_H_RES / 2;
            ball_w.y_pos = SCREEN_V_RES / 2;
        end
    end

    strobe_gen #(
        .BOARD_CLK_MHZ  ( BOARD_CLK_MHZ ),
        .STROBE_FREQ_HZ ( PLAYER_SPEED   )
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

    always_ff @(posedge clk_i)
        if (rst_i) begin
            player_o       <= '0;
            player_o.y_pos <= V_CENTER;

            enemy_o        <= '0;
            enemy_o.y_pos  <= V_CENTER;

            ball_o         <= '0;
        end else begin
            if (update_player)
                player_o <= player_w;

            if (update_enemy)
                enemy_o  <= enemy_w;

            if (new_frame_i)
                ball_o   <= ball_w;
        end

    assign player_w.right  = player_w.x_pos + PADDLE_WIDTH;
    assign player_w.bottom = player_w.y_pos + PADDLE_HEIGHT;

    assign enemy_w.right   = enemy_w.x_pos + PADDLE_WIDTH;
    assign enemy_w.bottom  = enemy_w.y_pos + PADDLE_HEIGHT;

    assign ball_w.right    = ball_w.x_pos + BALL_SIDE;
    assign ball_w.bottom   = ball_w.y_pos + BALL_SIDE;

    // Initialize FPGA registers on upload
    initial begin
        player_o.y_pos = V_CENTER;
    end

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

        if ((ball_o.x_pos > SCREEN_H_RES) || (ball_o.x_pos < SCREEN_BORDER)) begin
            ball_speed_x_w = { rnd_num[4], 2'b01,  rnd_num[7:6] };
            ball_speed_y_w = { rnd_num[5], 3'b000, rnd_num[8]   };
        end

        if (ball_o.y_pos < SCREEN_BORDER)
            ball_speed_y_w[SPEED_W-1] = 1'b0;

        if (ball_o.y_pos + SCREEN_BORDER > SCREEN_V_RES)
            ball_speed_y_w[SPEED_W-1] = 1'b1;
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
