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
    input in_cpt_mode,
    input in_cur_mode,
    input in_rmd_mode,
    output light_out,
    output display_menu,
    output display_01,
    output display_02,
    output display_03,
    output display_clean,
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
    output [3:0] row_out,
    output reg scan_input
);

    wire clk_out_en;
    wire clk_out_de;    
    wire [2:0] state;
    wire [5:0] sec;
    wire [5:0] min;
    wire [5:0] hour;
    wire power_on;
    wire [17:0] current_time;
    wire [17:0] work_time;
    wire [3:0] scan_key;
    wire [5:0] count_sec;
    wire [5:0] work_count_down;
    wire [5:0] time_limit_out;
    wire [31:0] tmp_count_cur;
    wire [31:0] tmp_count_rmd;
    
    reg [3:0] select;
    reg [1:0] cycle_count;
    reg power_flag_left, power_flag_right;
    reg [31:0] power_timer;
    reg power_button_sync, power_button_reg, power_button_stable; 
    reg [3:0] scan_key_sync, scan_key_stable;
    reg [31:0] scan_key_cnt;
    
    keyboard_driver key_dri_inst(
        .clk(clk),
        .rst(reset),
        .column(column),
        .row_out(row_out),
        .scan_key(scan_key)
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
        .clk(clk_out_de),
        .reset(reset & power_on),
        .current_time(current_time),
        .scan_key_stable(scan_key_stable),
        .in_mode(in_cur_mode),
        .tmp_count(tmp_count_cur)
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
    
    state_machine state_inst(
        .clk_de(clk_out_de),        
        .reset(reset),
        .power(power_on),
        .state_01(state_01),
        .state_02(state_02),
        .state_03(state_03),
        .state_clean_auto(state_clean_auto),
        .state_clean_manual(state_clean_manual),
        .menu(menu),
        .display_menu(display_menu),
        .display_01(display_01),
        .display_02(display_02),
        .display_03(display_03),
        .display_clean(display_clean),
        .work_time(work_time),
        .work_count_down(work_count_down),
        .state(state)
    );
    
    lighting_function lighting_function_inst (
        .power(reset & power_on),
        .light_in(light_in),
        .light_out(light_out)
    );
    
    search_function search_function_inst(
        .search_in(search_in),
        .state(state),
        .current_time(current_time),
        .work_time(work_time),
        .count_sec(count_sec),
        .work_count_down(work_count_down),
        .time_limit_out(time_limit_out),
        .sec(sec),
        .min(min),
        .hour(hour)
    );
    
    smart_reminder reminder_inst(
        .clk(clk_out_de),
        .rst(reset),
        .power(power_on),
        .in_mode(in_rmd_mode),
        .scan_key_stable(scan_key_stable),
        .work_time(work_time),
        .state_machine(state),
        .reminder(reminder),
        .tmp_count(tmp_count_rmd)
    );
    
    lcd1602_display lcd_inst(
        .clk(clk),
        .power(power_on),
        .in_cpt_mode(in_cpt_mode),
        .in_cur_mode(in_cur_mode),
        .in_rmd_mode(in_rmd_mode),
        .reminder(reminder),
        .state_machine(state),
        .work_count_down(work_count_down),
        .tmp_count_cur(tmp_count_cur),
        .tmp_count_rmd(tmp_count_rmd),
        .lcd_p(lcd_p),    //Backlight Source +
        .lcd_n(lcd_n),    //Backlight Source -
        .lcd_rs(lcd_rs),    //0:write order; 1:write data   
        .lcd_rw(lcd_rw),        //0:write data;  1:read data
        .lcd_en(lcd_en),    //negedge 
        .lcd_data(lcd_data)
    );
    
    power_set power_inst(
        .clk(clk),
        .rst(reset),
        .power_button(power_button),
        .scan_key_stable(scan_key_stable),
        .time_limit_out(time_limit_out),
        .in_mode(in_cpt_mode),
        .power_on(power_on),
        .count_sec(count_sec)
    );
    
    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            scan_input <= 1'b0;
            scan_key_sync <= 4'b1111;
            scan_key_stable <= 4'b1111;
            scan_key_cnt <= 0;
        end else begin
            if (scan_key == scan_key_sync) begin
                if (scan_key_cnt < 25'd4999999) begin
                    scan_key_cnt <= scan_key_cnt + 1;
                end else begin
                    scan_input <= 1'b1;
                    scan_key_stable <= scan_key;
                end
            end else begin
                scan_input <= 1'b0;
                scan_key_sync <= 4'b1111;
                scan_key_stable <= 4'b1111;
                scan_key_cnt <= 0;
            end
            scan_key_sync <= scan_key;  
        end
    end
    
    always @(posedge clk_out_en or posedge reset) begin
        if (~reset) begin
            select <= 4'd0;
        end else begin
            if (select == 4'd7) begin 
                select <= 4'd0;
            end else begin
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