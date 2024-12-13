`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 17:59:33
// Design Name: 
// Module Name: lcd1602_display
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


module lcd1602_display(
input clk,
input power,
input state_03,
input [2:0] state_machine,
input [5:0] work_count_down,
input in_cpt_mode,
input in_cur_mode,
input reminder,
output lcd_p,    //Backlight Source +
output lcd_n,    //Backlight Source -
output reg lcd_rs,    //0:write order; 1:write data   
output lcd_rw,        //0:write data;  1:read data
output reg lcd_en,    //negedge 
output reg [7:0] lcd_data,
output reg [5:0]time_count_down
    );
    assign lcd_n = 1'b0;
    assign lcd_p = 1'b1;
    assign lcd_rw = 1'b0;   //only write
    reg [31:0] cnt1;
    reg [71:0] data_display;
    reg [7:0] state_r0,state_r1;
    wire [7:0] data0,data1,data2,data3,data4,data5,data6,data7,data8; //counter data
    wire [7:0] data_r0,data_r1,data_r2;
    wire [7:0] addr;   //write address
    parameter   Mode_Set    =  8'h31,
                 Cursor_Set  =  8'h0c,
                 Address_Set =  8'h06,
                 Clear_Set   =  8'h01;

    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100,S5= 3'b101,S6= 3'b110, S7=3'b111;  

        assign data8 = data_display[71:64];
        assign data7 = data_display[63:56];
        assign data6 = data_display[55:48];
        assign data5 = data_display[47:40];
        assign data4 = data_display[39:32];
        assign data3 = data_display[31:24];
        assign data2 = data_display[23:16];
        assign data1 = data_display[15:8];
        assign data0 = data_display[7:0];

        assign data_r0 = time_count_down % 10;     
        assign data_r1 = (time_count_down - data_r0) / 10 ;
        assign data_r2 = (time_count_down - data_r1*10 - data_r0) / 10 ;      

    always@(state_machine)begin
        case(state_machine)
                S0: begin
                        time_count_down = 0;
                        if(in_cpt_mode||in_cur_mode) begin
                            data_display = {"-", "M","O","D","E",":","S","E","T"};
                        end else if(reminder) begin
                            data_display = {"N", "e", "e" ,"d", "C", "l", "e", "a", "n"};
                        end else begin
                            data_display = {"-", "S","t","a","n","d","b","y","-"};
                        end
                end
                S1: begin
                        time_count_down = 0;
                        data_display = {"-","M","O","D","E",":","L","v","1"};
                end
                S2: begin
                        time_count_down = 0;
                        data_display = {"-","M","O","D","E",":","L","v","2"};
                end
                S3: begin
                        time_count_down =  work_count_down;
                        data_display = {"-","T","i","m","e",":",8'h30 + data_r2,8'h30 + data_r1,8'h30 + data_r0};
                end
                S4: begin
                        time_count_down =  work_count_down;
                        data_display = {"C","l","e","a","n",":",8'h30 + data_r2,8'h30 + data_r1,8'h30 + data_r0};
                end
                S5: begin
                        time_count_down = 0;
                        data_display = {"P","o","w","e","r","-","O","f","f"};
                end
                S6: begin
                        time_count_down = 0;
                        data_display = {"-","I","n","-","M","e","n","u","-"};
                end
                S7: begin
                        time_count_down =  work_count_down;
                        data_display = {"-","T","i","m","e",":",8'h30 + data_r2,8'h30 + data_r1,8'h30 + data_r0};
                end
                default: begin
                        time_count_down =  0;
                        data_display = {"-","-","-","-","-","-","-","-","-"};
                end
        endcase
    end
            
           
                     
//-------------------address------------------
assign addr = 8'h80;
/****************************LCD1602 Driver****************************/             
//-----------------------lcd1602 clk_en---------------------
reg [31:0] cnt;
reg lcd_clk_en;
    always @(posedge clk) begin 
        if(power) begin
             if(cnt == 50000) begin   //500us
                 lcd_clk_en <= 1'b1;
                 cnt <= 1'b0;
             end else begin
                 cnt <= cnt + 1'b1;
                 lcd_clk_en <= 1'b0;
             end
         end else begin
             cnt <= 1'b0;
             lcd_clk_en <= 1'b0;
        end
     end 
                 
                 //-----------------------lcd1602 display state-------------------------------------------
reg [5:0] state;
     always@(posedge clk) begin
     if(power) begin
             if(lcd_clk_en)     
                 begin
                     case(state)
                         //-------------------init_state---------------------
                         6'd0: begin                
                                 lcd_rs <= 1'b0;
                                 lcd_en <= 1'b1;
                                 lcd_data <= Mode_Set;   
                                 state <= state + 1'd1;
                                 end
                         6'd1: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         6'd2: begin
                                 lcd_rs <= 1'b0;
                                 lcd_en <= 1'b1;
                                 lcd_data <= Cursor_Set;
                                 state <= state + 1'd1;
                                 end
                         6'd3: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         6'd4: begin
                                 lcd_rs <= 1'b0;
                                 lcd_en <= 1'b1;
                                 lcd_data <= Address_Set;
                                 state <= state + 1'd1;
                                 end
                         6'd5: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         6'd6: begin
                                 lcd_rs <= 1'b0;
                                 lcd_en <= 1'b1;
                                 lcd_data <= Clear_Set;
                                 state <= state + 1'd1;
                                 end
                         6'd7: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                                 
                         //--------------------work state--------------------
                         6'd8: begin              
                                 lcd_rs <= 1'b0;
                                 lcd_en <= 1'b1;
                                 lcd_data <= addr;   //write addr
                                 state <= state + 1'd1;
                                 end
                         6'd9: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         6'd10: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= data8;   //write data
                                 state <= state + 1'd1;
                                  end
                         6'd11: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         6'd12: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= data7;   //write data
                                 state <= state + 1'd1;
                                  end
                         6'd13: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         6'd14: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= data6;   //write data
                                 state <= state + 1'd1;
                                  end
                         6'd15: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         6'd16: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= data5;   //write data
                                 state <= state + 1'd1;
                                  end
                         6'd17: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end    
                         6'd18: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= data4;   //write data: tens digit
                                 state <= state + 1'd1;
                                  end
                         6'd19: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                  end
                         6'd20: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= data3;   //write data: single digit
                                 state <= state + 1'd1;
                                 end
                         6'd21: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                end
                         6'd22: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= data2;   //write data: single digit
                                 state <= state + 1'd1;
                                end
                         6'd23: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                end   
                          6'd24: begin
                                lcd_rs <= 1'b1;
                                lcd_en <= 1'b1;
                                lcd_data <= data1;   //write data: single digit
                                state <= state + 1'd1;
                               end
                        6'd25: begin 
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                end
                        6'd26: begin
                                lcd_rs <= 1'b1;
                                lcd_en <= 1'b1;
                                lcd_data <= data0;   //write data: single digit
                                state <= state + 1'd1;
                               end
                          6'd27: begin 
                                 lcd_en <= 1'b0;
                                 state <= 5'd8;
                                end 
                        //   6'd26: begin
                        //          lcd_rs <= 1'b1;
                        //          lcd_en <= 1'b1;
                        //          lcd_data <= "S";   //write addr
                        //          state <= state + 1'd1;
                        //          end
                        // 6'd27: begin
                        //          lcd_en <= 1'b0;
                        //          state <= state + 1'd1;
                        //          end
                        // 6'd28: begin
                        //          lcd_rs <= 1'b1;
                        //          lcd_en <= 1'b1;
                        //          lcd_data <= "t";   //write data
                        //          state <= state + 1'd1;
                        //           end
                        // 6'd29: begin
                        //          lcd_en <= 1'b0;
                        //          state <= state + 1'd1;
                        //          end    
                        // 6'd30: begin
                        //         lcd_rs <= 1'b1;
                        //         lcd_en <= 1'b1;
                        //         lcd_data <= "a";   //write data
                        //         state <= state + 1'd1;
                        //         end
                        // 6'd31: begin
                        //         lcd_en <= 1'b0;
                        //         state <= state + 1'd1;
                        //         end
                        // 6'd32: begin
                        //         lcd_rs <= 1'b1;
                        //         lcd_en <= 1'b1;
                        //         lcd_data <= "t";   //write data
                        //         state <= state + 1'd1;
                        //         end
                        // 6'd33: begin
                        //         lcd_en <= 1'b0;
                        //         state <= state + 1'd1;
                        //         end
                        // 6'd34: begin
                        //         lcd_rs <= 1'b1;
                        //         lcd_en <= 1'b1;
                        //         lcd_data <= "e";   //write data
                        //         state <= state + 1'd1;
                        //         end
                        // 6'd35: begin
                        //         lcd_en <= 1'b0;
                        //         state <= state + 1'd1;
                        //         end
                        // 6'd36: begin
                        //         lcd_rs <= 1'b1;
                        //         lcd_en <= 1'b1;
                        //         lcd_data <= ":";   //write data
                        //         state <= state + 1'd1;
                        //         end
                        // 6'd37: begin
                        //         lcd_en <= 1'b0;
                        //         state <= state + 1'd1;
                        //         end
                        // 6'd38: begin
                        //         lcd_rs <= 1'b1;
                        //         lcd_en <= 1'b1;
                        //         lcd_data <= state_r1;   //write data
                        //         state <= state + 1'd1;
                        //         end
                        // 6'd39: begin
                        //         lcd_en <= 1'b0;
                        //         state <= state + 1'd1;
                        //         end        
                        // 6'd40: begin
                        //         lcd_rs <= 1'b1;
                        //         lcd_en <= 1'b1;
                        //         lcd_data <= state_r0;   //write data
                        //         state <= state + 1'd1;
                        //         end
                        // 6'd41: begin
                        //         lcd_en <= 1'b0;
                        //         state <= 6'd8;
                        //         end     
                         default: state <= 6'bxxxxxx;
                     endcase
                 end
          end else begin
            state <= 1'b0;
            lcd_rs <= 1'b0;
            lcd_en <= 1'b0;
            lcd_data <= 1'b0; 
          end
     end

endmodule
