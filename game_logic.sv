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
    localparam [`Y_POS_W - 1:0] DOWN_LIMIT    = `SCREEN_V_RES - (`SCREEN_BORDER + `PADDLE_HEIGHT);
    localparam [`Y_POS_W - 1:0] PADDLE_CENTER = `PADDLE_HEIGHT / 2;

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

    logic                    collision_player;
    logic                    collision_pc;

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

    random i_random (
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

        // todo add signed speed, cause this shit is stupid
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

        if (collision_player)
            ball_speed_x_d[`BALL_SPEED_W - 1] = 1'b1;

        if (collision_pc)
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
