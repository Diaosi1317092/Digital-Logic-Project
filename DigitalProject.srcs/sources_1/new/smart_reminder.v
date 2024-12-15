`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/30 14:45:39
// Design Name: 
// Module Name: smart_remainder
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


module smart_reminder(
    input clk,
    input rst,
    input power,//开机
    input cleaned,
    input in_mode,
    input [17:0] work_time,
    input [3:0] scan_key_stable,
    input [2:0] State,
    output reg reminder,
    output reg [31:0] tmp_count
);
    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100,S5= 3'b101,S6= 3'b110; //待机、一档、二档、三档、自清洁
    parameter on=1'b1,off=1'b0;
    
    reg [17:0] limit_time =10;
    
    reg [31:0] next_count=0,next_tmp_count=0;
    reg [3:0] state,next_state;
    reg [3:0] lst_digit=15,now_digit=15;
    parameter A0 = 0,A1 = 1,A2 = 2,A3 = 3,A4 = 4,A5 = 5,A6 = 6,Ed=7;
    
    always @(posedge clk) begin
        if (power) begin
            if(State == S0|State == S6) begin
                if(work_time > limit_time & ~cleaned) begin
                    reminder <= on;
                end else begin
                    reminder <= off;
                end
            end else begin
                reminder <= off; 
            end
       end else begin
            reminder <= off;
       end
    end
    
    always @(posedge clk or posedge rst) begin// clk is clk_de
        if (~rst) begin
            limit_time <= 10;
            lst_digit<=15;
            now_digit<=15;
            state<=A0;
            tmp_count<=0;
        end else begin
            limit_time <= next_count;
            lst_digit=now_digit;// is = not <=
            state<=next_state;
            tmp_count<=next_tmp_count;
            case (scan_key_stable)// is = not <=
                0: now_digit=1;
                1: now_digit=4;
                2: now_digit=7;
                3: now_digit=10;//
                4: now_digit=2;
                5: now_digit=5;
                6: now_digit=8;
                7: now_digit=0;
                8: now_digit=3;
                9: now_digit=6;
                10: now_digit=9;
                11: now_digit=11;//
                12: now_digit=12;
                13: now_digit=13;
                14: now_digit=14;
                15: now_digit=15;
            endcase
        end
    end
    always @(*) begin 
        case (state) 
            A0: begin 
                next_count=limit_time;
                next_tmp_count=0;
                if (in_mode) begin
                    next_state=A1;
                end else begin 
                    next_state=A0;
                end
            end
            A1: begin 
                next_count=limit_time;
                if (!in_mode) begin
                    next_state=A0;
                    next_tmp_count=0;
                end else begin 
                    if (now_digit==15) begin 
                        if (lst_digit<=9) begin
                            next_state=A2;
                            next_tmp_count=tmp_count+lst_digit*100000;
                        end else if (lst_digit==12) begin 
                            next_state=A1;
                            next_tmp_count=0;
                        end else if (lst_digit==13) begin 
                            next_state=A1;
                            next_tmp_count=0;
                        end else if (lst_digit==14) begin 
                            next_state=Ed;
                            next_tmp_count=tmp_count;
                        end else begin 
                            next_state=state;
                            next_tmp_count=tmp_count;
                        end
                    end else begin 
                        next_state=state;
                        next_tmp_count=tmp_count;
                    end
                end
            end
            A2: begin 
                next_count=limit_time;
                if (!in_mode) begin
                    next_state=A0;
                    next_tmp_count=0;
                end else begin 
                    if (now_digit==15) begin 
                        if (lst_digit<=9) begin
                            next_state=A3;
                            next_tmp_count=tmp_count+lst_digit*10000;
                        end else if (lst_digit==12) begin 
                            next_state=A1;
                            next_tmp_count=0;
                        end else if (lst_digit==13) begin 
                            next_state=A1;
                            next_tmp_count=0;
                        end else if (lst_digit==14) begin 
                            next_state=Ed;
                            next_tmp_count=tmp_count;
                        end else begin 
                            next_state=state;
                            next_tmp_count=tmp_count;
                        end
                    end else begin 
                        next_state=state;
                        next_tmp_count=tmp_count;
                    end
                end
            end
            A3: begin 
                next_count=limit_time;
                if (!in_mode) begin
                    next_state=A0;
                    next_tmp_count=0;
                end else begin 
                    if (now_digit==15) begin 
                        if (lst_digit<=9) begin
                            next_state=A4;
                            next_tmp_count=tmp_count+lst_digit*1000;
                        end else if (lst_digit==12) begin 
                            next_state=A1;
                            next_tmp_count=0;
                        end else if (lst_digit==13) begin 
                            next_state=A2;
                            next_tmp_count=tmp_count/100000*100000;
                        end else if (lst_digit==14) begin 
                            next_state=Ed;
                            next_tmp_count=tmp_count;
                        end else begin 
                            next_state=state;
                            next_tmp_count=tmp_count;
                        end
                    end else begin 
                        next_state=state;
                        next_tmp_count=tmp_count;
                    end
                end
            end
            A4: begin 
                next_count=limit_time;
                if (!in_mode) begin
                    next_state=A0;
                    next_tmp_count=0;
                end else begin 
                    if (now_digit==15) begin 
                        if (lst_digit<=9) begin
                            next_state=A5;
                            next_tmp_count=tmp_count+lst_digit*100;
                        end else if (lst_digit==12) begin 
                            next_state=A1;
                            next_tmp_count=0;
                        end else if (lst_digit==13) begin 
                            next_state=A3;
                            next_tmp_count=tmp_count/10000*10000;
                        end else if (lst_digit==14) begin 
                            next_state=Ed;
                            next_tmp_count=tmp_count;
                        end else begin 
                            next_state=state;
                            next_tmp_count=tmp_count;
                        end
                    end else begin 
                        next_state=state;
                        next_tmp_count=tmp_count;
                    end
                end
            end
            A5: begin 
                next_count=limit_time;
                if (!in_mode) begin
                    next_state=A0;
                    next_tmp_count=0;
                end else begin 
                    if (now_digit==15) begin 
                        if (lst_digit<=9) begin
                            next_state=A6;
                            next_tmp_count=tmp_count+lst_digit*10;
                        end else if (lst_digit==12) begin 
                            next_state=A1;
                            next_tmp_count=0;
                        end else if (lst_digit==13) begin 
                            next_state=A4;
                            next_tmp_count=tmp_count/1000*1000;
                        end else if (lst_digit==14) begin 
                            next_state=Ed;
                            next_tmp_count=tmp_count;
                        end else begin 
                            next_state=state;
                            next_tmp_count=tmp_count;
                        end
                    end else begin 
                        next_state=state;
                        next_tmp_count=tmp_count;
                    end
                end
            end
            A6: begin 
                next_count=limit_time;
                if (!in_mode) begin
                    next_state=A0;
                    next_tmp_count=0;
                end else begin 
                    if (now_digit==15) begin 
                        if (lst_digit<=9) begin
                            next_state=Ed;
                            next_tmp_count=tmp_count+lst_digit*1;
                        end else if (lst_digit==12) begin 
                            next_state=A1;
                            next_tmp_count=0;
                        end else if (lst_digit==13) begin 
                            next_state=A5;
                            next_tmp_count=tmp_count/100*100;
                        end else if (lst_digit==14) begin 
                            next_state=Ed;
                            next_tmp_count=tmp_count;
                        end else begin 
                            next_state=state;
                            next_tmp_count=tmp_count;
                        end
                    end else begin 
                        next_state=state;
                        next_tmp_count=tmp_count;
                    end
                end
            end
            Ed: begin 
                if (!in_mode) begin
                    next_state=A0;
                    next_tmp_count=0;
                    next_count=tmp_count%100%60+tmp_count/100%100%60*64+tmp_count/10000%100%24*64*64;
                end else begin 
                    if (now_digit==15) begin 
                        if (lst_digit==12) begin 
                            next_state=A1;
                            next_tmp_count=0;
                            next_count=limit_time;
                        end else if (lst_digit==13) begin 
                            next_state=A6;
                            next_tmp_count=tmp_count/10*10;
                            next_count=limit_time;
                        end else begin 
                            next_state=state;
                            next_tmp_count=tmp_count;
                            next_count=limit_time;
                        end
                    end else begin 
                        next_state=state;
                        next_tmp_count=tmp_count;
                        next_count=limit_time;
                    end
                end
            end
        endcase
    end
    
endmodule
