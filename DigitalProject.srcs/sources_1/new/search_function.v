`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/01 15:58:19
// Design Name: 
// Module Name: search_function
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


module search_function(
input [1:0]search_in,
input [2:0] state,
input [17:0] current_time,
input [17:0] work_time,
input [5:0] count_sec,
input [5:0] work_count_down,
input [5:0] time_limit_out,
output [5:0] sec,
output [5:0] min,
output [5:0] hour
    );
parameter show_current_time=2'b00;
parameter show_work_time=2'b01;
parameter show_power_time=2'b10;//手势开关设置的时间 不是倒计时
parameter zero = 6'b0;
parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100,S5= 3'b101,S6= 3'b110,S7=3'b111;  

reg [17:0]output_time;
assign sec=output_time[5:0];
assign min=output_time[11:6];
assign hour=output_time[17:12];

    always@* begin
        case(search_in)
        show_current_time: begin
            if(count_sec > 0) begin
                output_time = {zero,zero,count_sec};//?????????
            end else if(state == S3|state == S7|state == S4) begin
                output_time = {zero,zero,work_count_down};
            end else begin 
                output_time = current_time;
            end
        end
        show_work_time: begin
            output_time = work_time;
        end
        show_power_time: begin
            output_time = time_limit_out;
        end
        default:
            output_time = current_time;
        endcase
    end
endmodule