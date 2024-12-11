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
    input state_clean_auto,
    input state_clean_manual,
    input light_in,
    input [1:0] search_in,
    input [3:0] column,
    output light_out,
    output display_menu,
    output display_01,
    output display_02,
    output display_03,
    output display_clean,
    output cleaned,//���������� ��ɾ�ɱ���
    output [7:0] seg1,
    output [7:0] seg2,
    output wire [7:0] an,
    output reminder,
    output lcd_p,    //Backlight Source +
    output lcd_n,    //Backlight Source -
    output lcd_rs,    //0:write order; 1:write data   
    output lcd_rw,        //0:write data;  1:read data
    output lcd_en,    //negedge 
    output [7:0] lcd_data,
    output finished,
    output [3:0] row_out     // ������ź�
);

    wire clk_out;
    wire clk_out_en;
    wire clk_out_de;    
    wire [2:0] State;
    wire [5:0] sec;
    wire [5:0] min;
    wire [5:0] hour;
    wire [17:0] current_time;//��¼����ʱ��
    wire [17:0] work_time;//��¼�ۼƹ���ʱ��
    wire [17:0] limit_time=10;//��¼���ú�������ʱ��
    wire [3:0] scan_key;     // ɨ�赽�İ���
    
    reg [3:0] select;
    reg [1:0] cycle_count;
    reg power_on;          // ��¼����״̬
    reg [31:0] power_timer;// ���ػ���ʱ��
    reg power_button_sync, power_button_reg, power_button_stable; // ȥ��������
    reg [3:0] scan_key_sync,scan_key_stable;
    reg [31:0] scan_key_cnt;
    
    keyboard_driver key_dri_inst(
        .clk(clk),
        .rst(reset),
        .column(column),
        .row_out(row_out),
        .scan_key(scan_key)
    );
    
    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            scan_key_sync <= 4'b1111;
            scan_key_stable <= 4'b1111;  
            scan_key_cnt <= 0;
        end else begin
            if (scan_key == scan_key_sync) begin
                if (scan_key_cnt < 25'd4999999) begin
                    scan_key_cnt <= scan_key_cnt + 1;
                end else begin
                    scan_key_stable <= scan_key;  
                end
            end else begin
                scan_key_sync <= 4'b1111;
                scan_key_stable <= 4'b1111;  
                scan_key_cnt <= 0;
            end
            scan_key_sync <= scan_key;  
        end
    end

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
    
    clock_divider_debounce clk_de_inst (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_out_de)
    );
    
    timer timer_inst (
        .clk(clk_out),
        .reset(reset & power_on),
        .current_time(current_time)
    );

    seven_segment_display display_inst (
        .sec(sec),
        .min(min),
        .hour(hour),
        .scan_key(scan_key_stable),
        .select(select),
        .seg1(seg1),
        .seg2(seg2),
        .an(an)
    );
    
    state_machine state_dut(
        .clk(clk_out),
        .clk_de(clk_out_de),        
        .reset(reset),
        .power(power_on),
        .state_01(state_01),
        .state_02(state_02),
        .state_03(state_03),
        .state_clean_auto(state_clean_auto),
        .state_clean_manual(state_clean_manual),
        .menu(menu),
        .finished(finished),
        .display_menu(display_menu),
        .display_01(display_01),
        .display_02(display_02),
        .display_03(display_03),
        .display_clean(display_clean),
        .cleaned(cleaned),
        .work_time(work_time),
        .State(State)
    );
    
    lighting_function lighting_function_inst (
        .power(reset & power_on),
        .light_in(light_in),
        .light_out(light_out)
    );
    
    search_function search_function_inst(
        .search_in(search_in),
        .current_time(current_time),
        .work_time(work_time),
        .sec(sec),
        .min(min),
        .hour(hour)
    );
    
    smart_reminder reminder_inst(
        .clk(clk_out),
        .power(power_on),
        .cleaned(cleaned),
        .work_time(work_time),
        .limit_time(limit_time),
        .State(State),
        .reminder(reminder)
    );
    
    lcd1602_display lcd_inst(
        .clk(clk),
        .power(power_on),
        .state_03(state_03),
        .state_machine(State),
        .lcd_p(lcd_p),    //Backlight Source +
        .lcd_n(lcd_n),    //Backlight Source -
        .lcd_rs(lcd_rs),    //0:write order; 1:write data   
        .lcd_rw(lcd_rw),        //0:write data;  1:read data
        .lcd_en(lcd_en),    //negedge 
        .lcd_data(lcd_data),
        .finished(finished)
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
            if (select == 4'd7) begin 
                select <= 4'd0;
            end
            else begin
                select <= select + 1;
            end
        end
    end

    assign an = (~reset || ~power_on) ? 8'b00000000 : 
                (select == 4'd0) ? 8'b10000000 :
                (select == 4'd1) ? 8'b01000000 :
                (select == 4'd2) ? 8'b00100000 :
                (select == 4'd3) ? 8'b00010000 : 
                (select == 4'd4) ? 8'b00001000 : 
                (select == 4'd5) ? 8'b00000100 : 
                (select == 4'd6) ? 8'b00000010 :
                (select == 4'd7) ? 8'b00000001 : 8'b11111111;
endmodule