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

    logic [`VGA_RGB_W - 1:0] player_rgb;
    logic [`VGA_RGB_W - 1:0] pc_rgb;
    logic [`VGA_RGB_W - 1:0] ball_rgb;

    // player
    sprite_display #(
        .RECT_W (`PLAYER_PADDLE_WIDTH),
        .RECT_H (`PLAYER_PADDLE_HEIGHT)
    ) i_player (
        .rect_x (player_paddle_x),
        .rect_y (player_paddle_y),
        .pixel_x (x_pos),
        .pixel_y (y_pos),
        .vga_rgb_o (player_rgb)
    );

    // computer
    sprite_display #(
        .RECT_W (`PC_PADDLE_WIDTH),
        .RECT_H (`PC_PADDLE_HEIGHT)
    ) i_computer (
        .rect_x (pc_paddle_x),
        .rect_y (pc_paddle_y),
        .pixel_x (x_pos),
        .pixel_y (y_pos),
        .vga_rgb_o (pc_rgb)
    );

    // ball
    sprite_display #(
        .RECT_W (`BALL_SIDE),
        .RECT_H (`BALL_SIDE)
    ) i_ball (
        .rect_x (ball_x),
        .rect_y (ball_y),
        .pixel_x (x_pos),
        .pixel_y (y_pos),
        .vga_rgb_o (ball_rgb)
    );

    assign vga_rgb_w = { 3 {|{ player_rgb, pc_rgb,  ball_rgb }}};

    always_ff @(posedge clk_i)
        if (rst_i)
            vga_rgb_o <= '0;
        else if (~visible_range)
            vga_rgb_o <= '0;
        else
            vga_rgb_o <= vga_rgb_w;

    // always_comb begin
    //     vga_rgb_o = '0;
    //
    //     if (visible_range) begin
    //         // Draw player paddle
    //         if (x_pos > `X_POS_W' (player_paddle_x) && x_pos < `X_POS_W' (32' (player_paddle_x) + `PLAYER_PADDLE_WIDTH) &&
    //             (y_pos > `Y_POS_W' (player_paddle_y) && y_pos < `Y_POS_W' (32' (player_paddle_y) + `PLAYER_PADDLE_HEIGHT))) begin
    //             vga_rgb_o = '1;
    //         end
    //
    //         // Draw computer paddle
    //         if (x_pos > `X_POS_W' (pc_paddle_x) && x_pos < `X_POS_W' (32' (pc_paddle_x) + `PC_PADDLE_WIDTH) &&
    //             (y_pos > `Y_POS_W' (pc_paddle_y) && y_pos < `Y_POS_W' (32' (pc_paddle_y) + `PC_PADDLE_HEIGHT))) begin
    //             vga_rgb_o = '1;
    //         end
    //
    //         // Draw ball
    //         if (x_pos > `X_POS_W' (ball_x) && x_pos < `X_POS_W' (32' (ball_x) + `BALL_SIDE) &&
    //             (y_pos > `Y_POS_W' (ball_y) && y_pos < `Y_POS_W' (32' (ball_y) + `BALL_SIDE))) begin
    //             vga_rgb_o = '1;
    //         end
    //
    //
    //         // if (x_pos > 320 && x_pos < 360 && y_pos > 240 && y_pos < 280)
    //         //     vga_rgb_o = '1;
    //     end
    // end

endmodule
