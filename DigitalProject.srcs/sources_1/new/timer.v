`timescale 1ns / 1ps
module timer (
    input clk,
    input reset,
    input in_mode,
    input [3:0] scan_key_stable,
    output [17:0] current_time
);
    reg [5:0] sec;
    reg [5:0] min;
    reg [5:0] hour;
    reg [31:0] count=0,next_count=0,tmp_count=0,next_tmp_count=0;
    reg [3:0] state,next_state;
    reg [3:0] lst_digit=15,now_digit=15;
    parameter A0 = 0,A1 = 1,A2 = 2,A3 = 3,A4 = 4,A5 = 5,A6 = 6,Ed=7;
    assign current_time={hour,min,sec};
    always @(posedge clk or posedge reset) begin// clk is clk_de
        if (~reset) begin
            count<=0;
            sec <= 0;
            min <= 0;
            hour <= 0;
            lst_digit<=15;
            now_digit<=15;
            state<=A0;
            tmp_count<=0;
        end else begin
            count<=next_count;
            sec<=next_count/100%60;
            min<=next_count/6000%60;
            hour<=next_count/360000%24;
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
                next_count=count+1;
                next_tmp_count=0;
                if (in_mode) begin
                    next_state=A1;
                end else begin 
                    next_state=A0;
                end
            end
            A1: begin 
                next_count=count+1;
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
                next_count=count+1;
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
                next_count=count+1;
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
                next_count=count+1;
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
                next_count=count+1;
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
                next_count=count+1;
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
                    next_count=tmp_count%100*100+tmp_count/100%100*6000+tmp_count/10000%100*360000;
                end else begin 
                    if (now_digit==15) begin 
                        if (lst_digit==12) begin 
                            next_state=A1;
                            next_tmp_count=0;
                            next_count=count+1;
                        end else if (lst_digit==13) begin 
                            next_state=A6;
                            next_tmp_count=tmp_count/10*10;
                            next_count=count+1;
                        end else begin 
                            next_state=state;
                            next_tmp_count=tmp_count;
                            next_count=count+1;
                        end
                    end else begin 
                        next_state=state;
                        next_tmp_count=tmp_count;
                        next_count=count+1;
                    end
                end
            end
        endcase
    end
//    always @(posedge clk or posedge reset) begin
//        if (~reset) begin
//            sec <= 0;
//            min <= 0;
//            hour <= 0;
//        end else begin
//            if (sec == 59) begin
//                sec <= 0;
//                if (min == 59) begin
//                    min <= 0;
//                    if (hour == 23) begin
//                        hour <= 0;
//                    end else begin
//                        hour <= hour + 1;
//                    end
//                end else begin
//                    min <= min + 1;
//                end
//            end else begin
//                sec <= sec + 1;
//            end
//        end
//    end
endmodule
