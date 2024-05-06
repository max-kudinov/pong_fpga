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
    initial begin
        player_paddle_y_o <= `Y_POS_W' (`SCREEN_V_RES / 2 - 32'(PADDLE_CENTER));
    end

    localparam [`Y_POS_W - 1:0] DOWN_LIMIT    = `SCREEN_V_RES - (`SCREEN_BORDER + `PADDLE_HEIGHT);
    localparam [`Y_POS_W - 1:0] PADDLE_CENTER = `PADDLE_HEIGHT / 2;

    logic                   update_pc;
    logic                   update_player;

    logic [`Y_POS_W - 1:0]  player_paddle_y_w;
    logic [`Y_POS_W - 1:0]  pc_paddle_y_w;
    logic [`Y_POS_W - 1:0]  pc_paddle_center;

    logic [`X_POS_W - 1:0]  ball_x_w;
    logic [`Y_POS_W - 1:0]  ball_y_w;

    logic [`BALL_SPEED_W - 1:0] ball_speed_x;
    logic [`BALL_SPEED_W - 1:0] ball_speed_y;

    logic [`BALL_SPEED_W - 1:0] ball_speed_x_w;
    logic [`BALL_SPEED_W - 1:0] ball_speed_y_w;

    logic [`RND_NUM_W - 1:0] rnd_num;

    logic                    key_up;
    logic                    key_down;

    logic                    collision_player;
    logic                    collision_pc;
    logic                    collision_player_tip_top;
    logic                    collision_player_tip_bottom;
    logic                    collision_pc_tip_top;
    logic                    collision_pc_tip_bottom;

    logic [`X_POS_W - 1:0]   player_paddle_right;
    logic [`Y_POS_W - 1:0]   player_paddle_bottom;

    logic [`X_POS_W - 1:0]   pc_paddle_right;
    logic [`Y_POS_W - 1:0]   pc_paddle_bottom;

    logic [`X_POS_W - 1:0]   ball_right;
    logic [`Y_POS_W - 1:0]   ball_bottom;

    assign player_paddle_right  =  player_paddle_x_o + `PADDLE_WIDTH;
    assign player_paddle_bottom =  player_paddle_y_o + `PADDLE_HEIGHT;

    assign pc_paddle_right      =  pc_paddle_x_o + `PADDLE_WIDTH;
    assign pc_paddle_bottom     =  pc_paddle_y_o + `PADDLE_HEIGHT;

    assign ball_right           =  ball_x_o + `BALL_SIDE;
    assign ball_bottom          =  ball_y_o + `BALL_SIDE;

    strobe_gen #(.STROBE_FREQ_HZ(`PC_SPEED)) i_pc_strobe_gen
    (
        .clk_i  ( clk_i  ),
        .rst_i  ( rst_i  ),
        .strobe ( update_pc )
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

    sprite_collision i_player_collision (
        .clk_i        ( clk_i                ),
        .rst_i        ( rst_i                ),
        .rect1_left   ( player_paddle_x_o    ),
        .rect1_right  ( player_paddle_right  ),
        .rect1_top    ( player_paddle_y_o    ),
        .rect1_bottom ( player_paddle_bottom ),
        .rect2_left   ( ball_x_o             ),
        .rect2_right  ( ball_right           ),
        .rect2_top    ( ball_y_o             ),
        .rect2_bottom ( ball_bottom          ),
        .collision    ( collision_player     )
    );

    sprite_collision i_player_collision_tip_top (
        .clk_i        ( clk_i                ),
        .rst_i        ( rst_i                ),
        .rect1_left   ( player_paddle_x_o    ),
        .rect1_right  ( player_paddle_right  ),
        .rect1_top    ( player_paddle_y_o    ),
        .rect1_bottom ( player_paddle_y_o + 1'b1 ),
        .rect2_left   ( ball_x_o             ),
        .rect2_right  ( ball_right           ),
        .rect2_top    ( ball_y_o             ),
        .rect2_bottom ( ball_bottom          ),
        .collision    ( collision_player_tip_top     )
    );

    sprite_collision i_player_collision_tip_bottom (
        .clk_i        ( clk_i                ),
        .rst_i        ( rst_i                ),
        .rect1_left   ( player_paddle_x_o    ),
        .rect1_right  ( player_paddle_right  ),
        .rect1_top    ( player_paddle_bottom - 1'b1   ),
        .rect1_bottom ( player_paddle_bottom ),
        .rect2_left   ( ball_x_o             ),
        .rect2_right  ( ball_right           ),
        .rect2_top    ( ball_y_o             ),
        .rect2_bottom ( ball_bottom          ),
        .collision    ( collision_player_tip_bottom     )
    );

    sprite_collision i_pc_collision_tip_top (
        .clk_i        ( clk_i            ),
        .rst_i        ( rst_i            ),
        .rect1_left   ( pc_paddle_x_o    ),
        .rect1_right  ( pc_paddle_right  ),
        .rect1_top    ( pc_paddle_y_o    ),
        .rect1_bottom ( pc_paddle_y_o + 1'b1),
        .rect2_left   ( ball_x_o         ),
        .rect2_right  ( ball_right       ),
        .rect2_top    ( ball_y_o         ),
        .rect2_bottom ( ball_bottom      ),
        .collision    ( collision_pc_tip_top     )
    );

    sprite_collision i_pc_collision_tip_bottom (
        .clk_i        ( clk_i            ),
        .rst_i        ( rst_i            ),
        .rect1_left   ( pc_paddle_x_o    ),
        .rect1_right  ( pc_paddle_right  ),
        .rect1_top    ( pc_paddle_bottom - 1'b1   ),
        .rect1_bottom ( pc_paddle_bottom ),
        .rect2_left   ( ball_x_o         ),
        .rect2_right  ( ball_right       ),
        .rect2_top    ( ball_y_o         ),
        .rect2_bottom ( ball_bottom      ),
        .collision    ( collision_pc_tip_bottom     )
    );

    sprite_collision i_pc_collision (
        .clk_i        ( clk_i            ),
        .rst_i        ( rst_i            ),
        .rect1_left   ( pc_paddle_x_o    ),
        .rect1_right  ( pc_paddle_right  ),
        .rect1_top    ( pc_paddle_y_o    ),
        .rect1_bottom ( pc_paddle_bottom ),
        .rect2_left   ( ball_x_o         ),
        .rect2_right  ( ball_right       ),
        .rect2_top    ( ball_y_o         ),
        .rect2_bottom ( ball_bottom      ),
        .collision    ( collision_pc     )
    );

    assign key_up   = keys_i[0];
    assign key_down = keys_i[1];

    always_comb begin
        // Calculate new player paddle coordinates
        player_paddle_y_w = player_paddle_y_o;

        // Move down
        if (key_down && (player_paddle_y_o < DOWN_LIMIT))
            player_paddle_y_w = player_paddle_y_o + 1'b1;

        // Move up
        if (key_up && (player_paddle_y_o > `SCREEN_BORDER))
            player_paddle_y_w = player_paddle_y_o - 1'b1;
    end

    always_ff @(posedge clk_i)
        if (rst_i) 
            player_paddle_y_o <= `Y_POS_W' (`SCREEN_V_RES / 2 - 32'(PADDLE_CENTER));
        else if (update_player) 
            player_paddle_y_o <= player_paddle_y_w;

    assign player_paddle_x_o = `X_POS_W' (`SCREEN_H_RES - 20); 

    always_comb begin
        // Calculate new computer paddle coordinates
        pc_paddle_y_w = pc_paddle_y_o;

        if ((pc_paddle_center > ball_y_o) && (pc_paddle_y_o > `SCREEN_BORDER))
            pc_paddle_y_w = pc_paddle_y_o - 1'b1;

        if ((pc_paddle_center < ball_y_o) && (pc_paddle_y_o < DOWN_LIMIT))
            pc_paddle_y_w = pc_paddle_y_o + 1'b1;
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            pc_paddle_center <= '0;
        else
            pc_paddle_center <= pc_paddle_y_o + PADDLE_CENTER;

    always_ff @(posedge clk_i)
        if (rst_i) 
            pc_paddle_y_o <= `Y_POS_W' (`SCREEN_V_RES / 2 - 32' (PADDLE_CENTER));
        else if (update_pc)
            pc_paddle_y_o <= pc_paddle_y_w;
        
    assign pc_paddle_x_o = `X_POS_W' (20); 

    always_comb begin
        // Calculate new ball coordinates
        if (ball_speed_x[`BALL_SPEED_W-1])
            ball_x_w = ball_x_o - `X_POS_W' (ball_speed_x[3:0]);
        else
            ball_x_w = ball_x_o + `X_POS_W' (ball_speed_x[3:0]);

        if (ball_speed_y[`BALL_SPEED_W-1])
            ball_y_w = ball_y_o - `Y_POS_W' (ball_speed_y[3:0]);
        else
            ball_y_w = ball_y_o + `Y_POS_W' (ball_speed_y[3:0]);

        if ((ball_x_o > `SCREEN_H_RES) || (ball_x_o < 1)) begin
            ball_x_w = `SCREEN_H_RES / 2;
            ball_y_w = `SCREEN_V_RES / 2;
        end
    end

    always_ff @(posedge clk_i)
        if (rst_i) begin
            ball_x_o     <= '0;
            ball_y_o     <= '0;
        end else if (new_frame_i) begin
            ball_x_o     <= ball_x_w;
            ball_y_o     <= ball_y_w;
        end

    always_comb begin
        // Calculate new ball speed
        ball_speed_x_w = ball_speed_x;
        ball_speed_y_w = ball_speed_y;

        if (collision_player) begin
            ball_speed_x_w = {4'b1100, rnd_num[0]};
            ball_speed_y_w[3:0] = {2'b00, rnd_num[1], 1'b1};
        end

        if (collision_pc) begin
            ball_speed_x_w = {4'b0100, rnd_num[2]};
            ball_speed_y_w[3:0] = {2'b00, rnd_num[3], 1'b1};
        end

        if (collision_player_tip_top || collision_pc_tip_top) begin
            ball_speed_y_w = 5'b10101; 
        end

        if (collision_player_tip_bottom || collision_pc_tip_bottom) begin
            ball_speed_y_w = 5'b00101; 
        end

        if ((ball_x_o > `SCREEN_H_RES) || (ball_x_o < 1)) begin
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
