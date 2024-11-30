`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/30 16:00:07
// Design Name: 
// Module Name: state_machine
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


module state_machine(
input clk,
input reset,
input power,
input menu,
input state_01,
input state_02,
input state_03,
input state_clean,//按钮输入
output display_menu,
output display_01,
output display_02,
output display_03,
output display_clean,//状态的LED显示
output reg cleaned
    );
parameter on=1'b1,off=1'b0;
parameter S0=3'b000,S1=3'b001,S2=3'b010,S3=3'b011,S4=3'b100;//待机、一档、二档、三档、自清洁
parameter wait_period_S3 = 4'b0110;//三档自动切换二档或者待机的市场
parameter wait_period_clean = 4'b0100;//自清洁的时长
reg [2:0] State;
reg [3:0] time_count_menu;
reg [3:0] time_count_S2;
reg [3:0] time_count_clean;
reg [4:0] display;
assign display_menu = display[0];
assign display_01 = display[1];
assign display_02 = display[2];
assign display_03 = display[3];
assign display_clean = display[4];
always@(posedge clk or negedge reset) begin
    if(power) begin
        if(~reset) begin
            State <= S0;
            display <= 5'b00001;
            cleaned <= off;
        end
        else begin
          case(State)
            S0: begin//不稳定会让切换档但是没松手的时候反复横跳待机状态
            display <= 5'b00001;
            cleaned <= off;
            if(state_01 & menu) begin
                    State <= S1;
                    end
                else if(state_02 & menu) begin
                    State <= S2;
                    end
                else if(state_03 & menu) begin
                    State <= S3;
                    time_count_menu <= 0;
                    time_count_S2 <= 0;
                    end
                else if(state_clean & menu) begin
                    State <= S4;
                    time_count_clean <= 0;
                    end
                else begin
                    State <= S0;
                    end
            end
            S1: begin
            display <= 5'b00010;
            if(state_02) begin
                    State <= S2;
                    end
                else if(menu) begin
                    State <= S0;
                    end
                else begin
                    State <= S1;
                    end
            end
            S2: begin
            display <= 5'b00100;
            if(state_01) begin
                    State <= S1;
                    end
                else if(menu) begin
                    State <= S0;
                    end
                else begin
                    State <= S2;
                    end
            end
            S3: begin
            display <= 5'b01000;
                if (menu) begin//这种写法好像不会有电平不稳定导致的问题 但是我的测试时间比较短 不知道会不会行不通
                    if (time_count_menu > wait_period_S3) begin
                        State <= S0;
                    end else begin
                        time_count_menu <= time_count_menu + 1;
                    end
                end else begin
                    time_count_S2 <= time_count_S2 + 1;
                    if (time_count_S2 > wait_period_S3) begin
                        State <= S2;
                    end
                end
                end
            S4: begin
                display <= 5'b10000;
                if (time_count_clean > wait_period_clean) begin
                    cleaned <= on;
                    State <= S0;
                end else begin
                    time_count_clean <= time_count_clean + 1;
                end
                end
            default:
                State <= S0;
            endcase
       end
    end else begin
    display <= 5'b00000;
    cleaned <= off;
    end
    
end
                    
endmodule
