`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/29 22:10:18
// Design Name: 
// Module Name: clock_divider
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


module clock_divider_enable (
    input clk,
    input reset,
    output reg clk_out
);
    parameter period = 1<<16;
    
    reg [24:0] count;
    
    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            count <= 0;
            clk_out <= 0;
        end else begin
            if (count == (period>>1)-1) begin
                count <= 0;
                clk_out <= ~clk_out;
            end else begin
                count <= count + 1;
            end
        end
    end
endmodule