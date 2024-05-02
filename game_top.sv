`include "config.svh"

module game_top (
    input  logic                    clk_i,
    input  logic                    rst_i,
    input  logic [`KEYS_W    - 1:0] keys_i,
    output logic [`LEDS_W    - 1:0] leds_o,
    output logic [`VGA_RGB_W - 1:0] vga_rgb_o,
    output logic                    vga_vs_o,
    output logic                    vga_hs_o
);

    logic [`X_POS_W - 1:0] x_pos;
    logic [`Y_POS_W - 1:0] y_pos;
    logic                  visible_range;

    // Player
    logic [`X_POS_W - 1:0] player_paddle_x;
    logic [`Y_POS_W - 1:0] player_paddle_y;

    // Computer
    logic [`X_POS_W - 1:0] pc_paddle_x;
    logic [`Y_POS_W - 1:0] pc_paddle_y;

    // Ball
    logic [`X_POS_W - 1:0] ball_x;
    logic [`Y_POS_W - 1:0] ball_y;
    logic [      7:0] ball_speed_x;
    logic [      7:0] ball_speed_y;

    logic             collision_player;
    logic             collision_pc;

    logic [`RND_NUM_W - 1:0] rnd_num;
    logic [`VGA_RGB_W - 1:0] vga_rgb_w;

    assign leds_o = keys_i;

    vga i_vga (
        .clk_i           ( clk_i         ),
        .rst_i           ( rst_i         ),
        .hsync_o         ( vga_hs_o      ),
        .vsync_o         ( vga_vs_o      ),
        .pixel_x_o       ( x_pos         ),
        .pixel_y_o       ( y_pos         ),
        .visible_range_o ( visible_range )
    );

    random i_random (
        .clk_i     ( clk_i   ),
        .rst_i     ( rst_i   ),
        .rnd_num_o ( rnd_num )
    );

    game_display i_game_display (
        .clk_i               ( clk_i           ),
        .rst_i               ( rst_i           ),
        .vga_x_pos_i         ( x_pos           ),
        .vga_y_pos_i         ( y_pos           ),
        .player_paddle_x_i   ( player_paddle_x ),
        .player_paddle_y_i   ( player_paddle_y ),
        .pc_paddle_x_i       ( pc_paddle_x     ),
        .pc_paddle_y_i       ( pc_paddle_y     ),
        .ball_x_i            ( ball_x          ),
        .ball_y_i            ( ball_y          ),
        .vga_visible_range_i ( visible_range   ),
        .vga_rgb_o           ( vga_rgb_o       )
    );

    logic last_vsync;
    logic frame_change;

    assign frame_change = last_vsync && ~vga_vs_o;

    always_ff @(posedge clk_i)
        if (rst_i)
            last_vsync <= '0;
        else
            last_vsync <= vga_vs_o;

    // Player paddle movement
    always_ff @(posedge clk_i)
        if (rst_i) player_paddle_y <= `Y_POS_W'( `SCREEN_V_RES / 2);
        else if (frame_change) begin
            if (keys_i[0] && player_paddle_y < (`Y_POS_W'(`SCREEN_V_RES) -
                `Y_POS_W'(`SCREEN_BORDER + `PLAYER_PADDLE_HEIGHT)))
                player_paddle_y <= player_paddle_y + `Y_POS_W'(`PLAYER_PADDLE_SPEED);

            if (keys_i[1] && player_paddle_y > `Y_POS_W'(`SCREEN_BORDER))
                player_paddle_y <= player_paddle_y - `Y_POS_W'(`PLAYER_PADDLE_SPEED);
        end

    // Computer paddle movement
    always_ff @(posedge clk_i)
        if (rst_i)
            pc_paddle_y <= `Y_POS_W'( `SCREEN_V_RES / 2);
        else if (frame_change) begin
            if (pc_paddle_y + `PC_PADDLE_HEIGHT / 4 > ball_y && pc_paddle_y > `SCREEN_BORDER)
                pc_paddle_y <= pc_paddle_y - `Y_POS_W' (`PC_PADDLE_SPEED);

            else if (pc_paddle_y + `PC_PADDLE_HEIGHT - 5 < ball_y &&
                pc_paddle_y + `PC_PADDLE_HEIGHT < `SCREEN_V_RES - `SCREEN_BORDER)
                pc_paddle_y <= pc_paddle_y + `Y_POS_W' (`PC_PADDLE_SPEED);

            // pc_paddle_y <= ball_y;
        end

    // Ball movement
    always_ff @(posedge clk_i)
        if (rst_i) begin
            ball_x     <= `X_POS_W'(`SCREEN_H_RES / 2);
            ball_y     <= `Y_POS_W'(`SCREEN_V_RES / 2);
            ball_speed_x <= 8'd3;
            ball_speed_y <= 8'd2;
        end else if (frame_change) begin
            if (ball_speed_x[7])
                ball_x <= ball_x - ball_speed_x[6:0];
            else
                ball_x <= ball_x + ball_speed_x[6:0];

            if (ball_speed_y[7])
                ball_y <= ball_y - ball_speed_y[6:0];
            else
                ball_y <= ball_y + ball_speed_y[6:0];

            if (collision_player) begin
                ball_speed_x[7]   <= 1'b1;
                // ball_speed_x[6:0] <= 7' ({ rnd_num[3:2], 1'b1 });
                // ball_speed_y[6:0] <= 7' (rnd_num[1:0]);
            end

            if (collision_pc) begin
                ball_speed_x[7]   <= 1'b0;
                // ball_speed_x[6:0] <= 7' ({ rnd_num[3:2], 1'b1 });
                // ball_speed_y[6:0] <= 7' (rnd_num[1:0]);
            end

            if ((ball_x > `SCREEN_H_RES) || (ball_x < 1)) begin
                ball_x <= `SCREEN_H_RES / 2;
                ball_y <= `SCREEN_V_RES / 2;

                ball_speed_x[7]   <=    (rnd_num[`RND_NUM_W - 1]);
                // ball_speed_x[6:0] <= 7' (rnd_num[3:2] + 1'b1);
                ball_speed_y[7]   <=    (rnd_num[0]);
                // ball_speed_y[6:0] <= 7' (rnd_num[1:0]);
            end

            if (ball_y < 5)
                ball_speed_y[7] <= 1'b0;
            if (ball_y + 10 > `SCREEN_V_RES)
                ball_speed_y[7] <= 1'b1;
        end

    assign player_paddle_x = `X_POS_W'(`SCREEN_H_RES - 20);
    assign pc_paddle_x     = `X_POS_W'(20);

    always_comb begin
        collision_player = '0;
        collision_pc     = '0;

        // Check collision with player paddle
        if ((player_paddle_x < ball_x          + `BALL_SIDE) &&
            (ball_y          < player_paddle_y + `PLAYER_PADDLE_HEIGHT) &&
            (player_paddle_y < ball_y          + `SCREEN_BORDER))
            collision_player = 1'b1;

        // Check collision with computer paddle
        if ((ball_x      < pc_paddle_x + `BALL_SIDE) &&
            (ball_y      < pc_paddle_y + `PC_PADDLE_HEIGHT) &&
            (pc_paddle_y < ball_y      + `SCREEN_BORDER))
            collision_pc = 1'b1;
    end

endmodule
