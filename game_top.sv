module game_top #(
    parameter CLK_MHZ = 50,
    parameter H_RES   = 640,
    parameter V_RES   = 480
) (
    input  logic       clk_i,
    input  logic       rst_i,
    input  logic [1:0] keys_i,
    output logic [1:0] leds_o,
    output logic [2:0] vga_rgb_o,
    output logic       vga_vs_o,
    output logic       vga_hs_o
);

    localparam x_w = $clog2(H_RES);
    localparam y_w = $clog2(V_RES);

    logic [x_w - 1:0] pixel_x;
    logic [y_w - 1:0] pixel_y;
    logic             visible_range;

    // Player
    logic [  x_w-1:0] player_paddle_x;
    logic [  y_w-1:0] player_paddle_y;

    // Computer
    logic [  x_w-1:0] pc_paddle_x;
    logic [  y_w-1:0] pc_paddle_y;

    // Ball 
    logic [  x_w-1:0] ball_x;
    logic [  y_w-1:0] ball_y;
    logic [      7:0] ball_speed;

    logic             collision_player;
    logic             collision_pc;

    assign leds_o = keys_i;

    vga #(
        .CLK_MHZ(CLK_MHZ),
        .H_RES  (H_RES),
        .V_RES  (V_RES),
        .X_POS_W(x_w),
        .Y_POS_W(y_w)
    ) i_vga (
        .clk_i           (clk_i),
        .rst_i           (rst_i),
        .hsync_o         (vga_hs_o),
        .vsync_o         (vga_vs_o),
        .pixel_x_o       (pixel_x),
        .pixel_y_o       (pixel_y),
        .visible_range_o (visible_range)
    );

    logic last_vsync;
    logic frame_change;

    assign frame_change = ~last_vsync && vga_vs_o;

    always_ff @(posedge clk_i)
        if (rst_i) last_vsync <= '0;
        else last_vsync <= vga_vs_o;

    // Player paddle movement
    always_ff @(posedge clk_i)
        if (rst_i) player_paddle_y <= y_w'(V_RES / 2);
        else if (frame_change) begin
            if (keys_i[0] && player_paddle_y < (y_w'(V_RES) - y_w'(10 + 50)))
                player_paddle_y <= player_paddle_y + y_w'(5);

            if (keys_i[1] && player_paddle_y > y_w'(10))
                player_paddle_y <= player_paddle_y - y_w'(5);
        end

    // Computer paddle movement
    always_ff @(posedge clk_i)
        if (rst_i) pc_paddle_y <= y_w'(V_RES / 2);
        else if (frame_change) begin
            if (keys_i[0] && pc_paddle_y < (y_w'(V_RES) - y_w'(10 + 50)))
                pc_paddle_y <= pc_paddle_y + y_w'(5);

            if (keys_i[1] && pc_paddle_y > y_w'(10)) pc_paddle_y <= pc_paddle_y - y_w'(5);
        end

    // Ball movement
    always_ff @(posedge clk_i)
        if (rst_i) begin
            ball_x     <= x_w'(320);
            ball_speed <= 8'd2;
        end else if (frame_change) begin
            if (ball_speed[7]) ball_x <= ball_x - ball_speed[6:0];
            else ball_x <= ball_x + ball_speed[6:0];

            if (collision_player) begin
                ball_speed[7] <= 1'b1;
                // ball_speed[6:0] <= ball_speed + 1'b1;
            end else if (collision_pc) begin
                ball_speed[7] <= 1'b0;
                // ball_speed[6:0] <= ball_speed + 1'b1;
            end

            if ((ball_x > H_RES) || (ball_x < 1)) ball_x <= 320;
        end

    assign player_paddle_x = x_w'(H_RES - 20);
    assign pc_paddle_x     = x_w'(20);
    assign ball_y          = y_w'(V_RES / 2);

    always_comb begin
        collision_player = '0;
        collision_pc     = '0;

        // Check collision with player paddle
        if ((player_paddle_x < ball_x          + 10) && 
            (ball_y          < player_paddle_y + 50) && 
            (player_paddle_y < ball_y          + 10))
            collision_player = 1'b1;

        // Check collision with computer paddle
        if ((ball_x      < pc_paddle_x + 10) && 
            (ball_y      < pc_paddle_y + 50) && 
            (pc_paddle_y < ball_y      + 10))
            collision_pc = 1'b1;
    end

    always_comb begin
        vga_rgb_o = '0;

        if (visible_range) begin
            // Draw player paddle
            if (pixel_x > x_w' (player_paddle_x) && pixel_x < x_w' (32' (player_paddle_x) + 10) &&
                (pixel_y > y_w' (player_paddle_y) && pixel_y < y_w' (32' (player_paddle_y) + 50))) begin
                vga_rgb_o = '1;
            end

            // Draw computer paddle
            if (pixel_x > x_w' (pc_paddle_x) && pixel_x < x_w' (32' (pc_paddle_x) + 10) &&
                (pixel_y > y_w' (pc_paddle_y) && pixel_y < y_w' (32' (pc_paddle_y) + 50))) begin
                vga_rgb_o = '1;
            end

            // Draw ball
            if (pixel_x > x_w' (ball_x) && pixel_x < x_w' (32' (ball_x) + 10) &&
                (pixel_y > y_w' (ball_y) && pixel_y < y_w' (32' (ball_y) + 10))) begin
                vga_rgb_o = '1;
            end
        end
    end

endmodule
