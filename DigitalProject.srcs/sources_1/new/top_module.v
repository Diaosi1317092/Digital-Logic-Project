`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/29 21:50:36
// Design Name: 
// Module Name: top_module
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

module top_module (
    input clk,
    input reset,
    input power_button,
    input menu,
    input state_01,
    input state_02,
    input state_03,
    input state_clean,
    input light_in,
    output light_out,
    output display_menu,
    output display_01,
    output display_02,
    output display_03,
    output display_clean,
    output cleaned,
    output [7:0] seg1,
    output [7:0] seg2,
    output wire [5:0] an
);

    wire clk_out;
    wire clk_out_en;
    wire [5:0] sec;
    wire [5:0] min;
    wire [5:0] hour;
    reg [3:0] select;
    reg [1:0] cycle_count;
    reg power_on;          // ��¼����״̬
    reg [31:0] power_timer;// ���ػ���ʱ��
    reg power_button_sync, power_button_reg, power_button_stable; // ȥ��������

    clock_divider clk_div_inst (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_out)
    );
    
    clock_divider_enable clk_en_inst (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_out_en)
    );

    timer timer_inst (
        .clk(clk_out),
        .reset(reset & power_on),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    seven_segment_display display_inst (
        .sec(sec),
        .min(min),
        .hour(hour),
        .select(select),
        .seg1(seg1),
        .seg2(seg2),
        .an(an)
    );
    
    state_machine state_dut(
        .clk(clk_out),
        .reset(reset),
        .power(power_on),
        .state_01(state_01),
        .state_02(state_02),
        .state_03(state_03),
        .state_clean(state_clean),
        .menu(menu),
        .display_menu(display_menu),
        .display_01(display_01),
        .display_02(display_02),
        .display_03(display_03),
        .display_clean(display_clean),
        .cleaned(cleaned)
    );
    
    lighting_function lighting_function_inst (
        .power(reset & power_on),
        .light_in(light_in),
        .light_out(light_out)
    );
    
    always @(posedge clk) begin
        power_button_sync <= power_button;      // ����ť״̬
        power_button_stable <= power_button_sync;  // �ȶ��İ�ť�ź�
    end
    
   always @(posedge clk or posedge reset) begin
        if (~reset) begin
            power_on <= 1'b0;
            power_timer <= 32'd0;
        end else if (power_button_stable) begin  // ֻ�а�ť�ȶ�ʱ�Ŵ���
            if (power_on == 1'b0) begin
                if (power_timer < 32'd100000000) begin // �ȴ� 1 �� 
                    power_timer <= power_timer + 1;
                end else begin
                    power_on <= 1'b1; // ���� 1 ��󿪻�
                    power_timer <= 32'd0; // ���ü�ʱ��
                end
            end else begin
                if (power_timer < 32'd300000000) begin // �ȴ� 3 ��
                    power_timer <= power_timer + 1;
                end else begin
                    power_on <= 1'b0; // ���� 3 ���ػ�
                    power_timer <= 32'd0; // ���ü�ʱ��
                end
            end
        end else begin
            power_timer <= 32'd0;  // û�а���ʱ����ʱ������
        end
    end
    
    always @(posedge clk_out_en or posedge reset) begin
        if (~reset) begin
            select <= 4'd0;
        end else begin
            if (select == 4'd5) begin 
                select <= 4'd0;
            end
            else begin
                select <= select + 1;
            end
        end
    end

    assign an = (~reset || ~power_on) ? 6'b000000 : 
                (select == 4'd0) ? 6'b100000 :
                (select == 4'd1) ? 6'b010000 :
                (select == 4'd2) ? 6'b001000 :
                (select == 4'd3) ? 6'b000100 : 
                (select == 4'd4) ? 6'b000010 : 
                (select == 4'd5) ? 6'b000001 : 6'b111111;
endmodule




