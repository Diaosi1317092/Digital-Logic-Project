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
input [2:0]state_machine,
output lcd_p,    //Backlight Source +
output lcd_n,    //Backlight Source -
output reg lcd_rs,    //0:write order; 1:write data   
output lcd_rw,        //0:write data;  1:read data
output reg lcd_en,    //negedge 
output reg [7:0] lcd_data,
output reg finished
    );
    assign lcd_n = 1'b0;
    assign lcd_p = 1'b1;
    assign lcd_rw = 1'b0;   //only write
    reg [31:0] cnt1;
    reg [7:0] time_count;
    wire [7:0] time_count_down;
    wire [7:0] data0,data1,data2; //counter data
    wire [7:0] data_r0,data_r1,data_r2;
    wire [7:0] addr;   //write address
    parameter   Mode_Set    =  8'h31,
                 Cursor_Set  =  8'h0c,
                 Address_Set =  8'h06,
                 Clear_Set   =  8'h01,
                 time_limit = 10,
                 S3 = 3'b011;
                 
   assign time_count_down = time_limit - time_count ;
   assign data_r0 = time_count_down % 10;     
   assign data_r1 = (time_count_down - data_r0) / 10 ;
   assign data_r2 = (time_count_down - data_r1*10 - data_r0) / 10 ;
   assign data0 = 8'h30 + data_r0;
   assign data1 = 8'h30 + data_r1;
   assign data2 = 8'h30 + data_r2;                  
                     
    always@(posedge clk) begin
        if(power & state_machine == S3) begin
          if(cnt1==100000000) begin
              if(time_count < time_limit) begin
                 time_count <= time_count + 1 ;
              end else begin
                 time_count <= time_count ;
                 finished <= 1'b1;
              end
              cnt1 <= 1'b0;
          end else begin
              cnt1 <= cnt1 + 1;
          end
         end else begin
            cnt1 <= 1'b0;
            time_count <= 0;
            finished <= 0;   
        end
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
reg [4:0] state;
     always@(posedge clk) begin
     if(power) begin
             if(lcd_clk_en)     
                 begin
                     case(state)
                         //-------------------init_state---------------------
                         5'd0: begin                
                                 lcd_rs <= 1'b0;
                                 lcd_en <= 1'b1;
                                 lcd_data <= Mode_Set;   
                                 state <= state + 1'd1;
                                 end
                         5'd1: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         5'd2: begin
                                 lcd_rs <= 1'b0;
                                 lcd_en <= 1'b1;
                                 lcd_data <= Cursor_Set;
                                 state <= state + 1'd1;
                                 end
                         5'd3: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         5'd4: begin
                                 lcd_rs <= 1'b0;
                                 lcd_en <= 1'b1;
                                 lcd_data <= Address_Set;
                                 state <= state + 1'd1;
                                 end
                         5'd5: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         5'd6: begin
                                 lcd_rs <= 1'b0;
                                 lcd_en <= 1'b1;
                                 lcd_data <= Clear_Set;
                                 state <= state + 1'd1;
                                 end
                         5'd7: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                                 
                         //--------------------work state--------------------
                         5'd8: begin              
                                 lcd_rs <= 1'b0;
                                 lcd_en <= 1'b1;
                                 lcd_data <= addr;   //write addr
                                 state <= state + 1'd1;
                                 end
                         5'd9: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         5'd10: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= "T";   //write data
                                 state <= state + 1'd1;
                                  end
                         5'd11: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         5'd12: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= "i";   //write data
                                 state <= state + 1'd1;
                                  end
                         5'd13: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         5'd14: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= "m";   //write data
                                 state <= state + 1'd1;
                                  end
                         5'd15: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end
                         5'd16: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= "e";   //write data
                                 state <= state + 1'd1;
                                  end
                         5'd17: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                 end    
                         5'd18: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= ":";   //write data: tens digit
                                 state <= state + 1'd1;
                                  end
                         5'd19: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                  end
                         5'd20: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= data2;   //write data: single digit
                                 state <= state + 1'd1;
                                 end
                         5'd21: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                end
                         5'd22: begin
                                 lcd_rs <= 1'b1;
                                 lcd_en <= 1'b1;
                                 lcd_data <= data1;   //write data: single digit
                                 state <= state + 1'd1;
                                end
                         5'd23: begin
                                 lcd_en <= 1'b0;
                                 state <= state + 1'd1;
                                end   
                          5'd24: begin
                                lcd_rs <= 1'b1;
                                lcd_en <= 1'b1;
                                lcd_data <= data0;   //write data: single digit
                                state <= state + 1'd1;
                               end
                          5'd25: begin 
                                 lcd_en <= 1'b0;
                                 state <= 5'd8;
                                end              
                         default: state <= 5'bxxxxx;
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
