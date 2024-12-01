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
input [17:0] current_time,
input [17:0] work_time,
output [5:0] sec,
output [5:0] min,
output [5:0] hour
    );
parameter show_current_time=2'b00;
parameter show_work_time=2'b01;
reg [17:0]output_time;
assign sec=output_time[5:0];
assign min=output_time[11:6];
assign hour=output_time[17:12];

    always@* begin
        case(search_in)
        show_current_time: begin
            output_time <= current_time;
        end
        show_work_time: begin
            output_time <= work_time;
        end
        default:
            output_time <= current_time;
        endcase
    end
endmodule