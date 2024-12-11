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
input power,//开机
input cleaned,
input [17:0] work_time,
input [17:0] limit_time,
input [2:0] State,
output reg reminder
    );
    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100,S5= 3'b101,S6= 3'b110; //待机、一档、二档、三档、自清洁
    parameter on=1'b1,off=1'b0;
    
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
endmodule
