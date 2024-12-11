`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 22:42:08
// Design Name: 
// Module Name: change_power_time
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


module change_power_time(
    input clk,
    input rst,
    input in_mode,
    input [3:0] scan_key_stable,
    output wire [6:0] time_limit
);
//    always @(posedge clk or posedge rst) begin
//        if(~rst) begin
//            time_limit <= 5;
//        end else if (in_mode) begin
//            if (scan_key_stable == 4'b0000) begin
//                time_limit <= 1;
//            end else if (scan_key_stable == 4'b0100) begin
//                time_limit <= 2;
//            end else if (scan_key_stable == 4'b1000) begin
//                time_limit <= 3;
//            end else if (scan_key_stable == 4'b0001) begin
//                time_limit <= 4;
//            end else if (scan_key_stable == 4'b0101) begin
//                time_limit <= 5;
//            end else if (scan_key_stable == 4'b1001) begin
//                time_limit <= 6;
//            end else if (scan_key_stable == 4'b0010) begin
//                time_limit <= 7;
//            end else if (scan_key_stable == 4'b0110) begin
//                time_limit <= 8;
//            end else if (scan_key_stable == 4'b1010) begin
//                time_limit <= 9;
//            end else begin
//                time_limit <= time_limit;
//            end
//        end else begin
//            time_limit <= time_limit;
//        end
//    end
endmodule
