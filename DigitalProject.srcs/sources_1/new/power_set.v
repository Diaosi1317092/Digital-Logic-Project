`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 15:20:02
// Design Name: 
// Module Name: power_set
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module power_set(
    input clk,
    input rst,
    input power_button,
    input [3:0] scan_key_stable,
    input in_mode,
    output reg power_on,
    output reg [5:0] count_sec,
    output [5:0] time_limit_out
);
    reg [5:0] time_limit = 6'd5;
    reg power_flag_left, power_flag_right;          // 记录开机状态
    reg [31:0] power_timer;// 开关机计时器
    reg power_button_sync, power_button_reg, power_button_stable; // 去抖动处理
    assign time_limit_out = time_limit;

    always @(posedge clk) begin
        power_button_sync <= power_button;      // 捕获按钮状态
        power_button_stable <= power_button_sync;  // 稳定的按钮信号
    end
    
    always @(posedge clk or posedge rst) begin
        if (~rst) begin
            power_flag_left <= 1'b0;
            power_flag_right <= 1'b0;
            power_on <= 1'b0;
            power_timer <= 32'd0;
            count_sec <= 6'd0;
        end else if (power_button_stable) begin  // 只有按钮稳定时才处理
            if (power_on == 1'b0) begin
                if (power_timer < 32'd100000000) begin // 等待 1 秒 
                    power_timer <= power_timer + 1;
                end else begin
                    power_on <= 1'b1; // 持续 1 秒后开机
                    power_timer <= 32'd0; // 重置计时器
                end
            end else begin
                if (power_timer < 32'd300000000) begin // 等待 3 秒
                    power_timer <= power_timer + 1;
                end else begin
                    power_on <= 1'b0; // 持续 3 秒后关机
                    power_timer <= 32'd0; // 重置计时器
                end
            end
        end else if (scan_key_stable == 4'b0011) begin
            power_flag_left <= 1'b1;
        end else if (scan_key_stable == 4'b1011) begin
            power_flag_right <= 1'b1;
        end else if (power_flag_left) begin
            if (power_timer < time_limit * 32'd100000000) begin // 等待 5 秒 
                power_timer <= power_timer + 1;
                count_sec <= time_limit - (power_timer / 32'd100000000) ;
                if (power_flag_right) begin
                    power_on <= ~power_on; // 持续 5 秒后开机
                    power_timer <= 32'd0; // 重置计时器
                    count_sec <= 6'd0;
                    power_flag_left <= 1'b0;
                    power_flag_right <= 1'b0;
                end else begin
                
                end
            end else begin
                power_timer <= 32'd0; // 重置计时器
                count_sec <= 6'd0;
                power_flag_left <= 1'b0;
                power_flag_right <= 1'b0;
            end
        end else if (power_flag_right) begin
            if (power_timer < time_limit * 32'd100000000) begin // 等待 5 秒 
                power_timer <= power_timer + 1;
                count_sec <= time_limit - (power_timer / 32'd100000000) ;
                if (power_flag_left) begin
                    power_on <= ~power_on; // 持续 5 秒后关机
                    power_timer <= 32'd0; // 重置计时器
                    count_sec <= 6'd0;
                    power_flag_left <= 1'b0;
                    power_flag_right <= 1'b0;
                end else begin
                    
                end
            end else begin
                power_timer <= 32'd0; // 重置计时器
                count_sec <= 6'd0;
                power_flag_left <= 1'b0;
                power_flag_right <= 1'b0;
            end
        end else if (scan_key_stable != 4'b1111 && scan_key_stable != 4'b0011 && scan_key_stable != 4'b1011) begin
            power_flag_left <= 1'b0;
            power_flag_right <= 1'b0;
        end else begin
            power_timer <= 32'd0;  // 没有按下时，计时器清零
            count_sec <= 6'd0;
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if(~rst) begin
            time_limit <= 5;
        end else if (in_mode) begin
            if (scan_key_stable == 4'b0000) begin
                time_limit <= 1;
            end else if (scan_key_stable == 4'b0100) begin
                time_limit <= 2;
            end else if (scan_key_stable == 4'b1000) begin
                time_limit <= 3;
            end else if (scan_key_stable == 4'b0001) begin
                time_limit <= 4;
            end else if (scan_key_stable == 4'b0101) begin
                time_limit <= 5;
            end else if (scan_key_stable == 4'b1001) begin
                time_limit <= 6;
            end else if (scan_key_stable == 4'b0010) begin
                time_limit <= 7;
            end else if (scan_key_stable == 4'b0110) begin
                time_limit <= 8;
            end else if (scan_key_stable == 4'b1010) begin
                time_limit <= 9;
            end else begin
                time_limit <= time_limit;
            end
        end else begin
            time_limit <= time_limit;
        end
    end

endmodule
