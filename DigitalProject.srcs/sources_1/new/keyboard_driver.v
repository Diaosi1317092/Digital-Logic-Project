`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/10 21:50:52
// Design Name: 
// Module Name: keyboard_driver
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


module keyboard_driver(
    input clk,                    // 系统时钟 (100MHz)
    input rst,                    // 复位信号
    input [3:0] column,           // 列输入信号
    output reg [3:0] row_out,     // 行输出信号
    output reg [3:0] scan_key     // 扫描到的按键
); 

reg [3:0] row_int;              // 内部寄存器，控制行扫描
reg [31:0] cnt_scan;            // 扫描计数器
reg sign;                       // sign = 1: 停止扫描, sign = 0: 继续扫描
reg restart;                    // 是否重新开始扫描
reg [3:0] column_debounce;      // 消抖后的列状态
reg [3:0] column_debounce_d;    // 前一周期的列状态
reg [7:0] debounce_cnt;         // 列防抖计数器

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        debounce_cnt <= 0;
        column_debounce <= 4'b1111; 
        column_debounce_d <= 4'b1111;
    end else begin
        debounce_cnt <= debounce_cnt + 1;
        if (debounce_cnt == 8'd9) begin
            column_debounce <= column;
            column_debounce_d <= column_debounce;
        end
    end
end

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        row_int <= 4'b1110;         
        cnt_scan <= 0;              
    end else begin
        if (sign == 1'b0) begin
            restart <= 0;
            cnt_scan <= cnt_scan + 1;  
            row_int[3:1] <= row_int[2:0]; 
            row_int[0] <= row_int[3];    
        end else if (sign == 1'b1) begin
            if (column_debounce == 4'b1111)  
                restart <= 1;
        end
    end
end

reg [3:0] row_stable;           
reg [7:0] row_debounce_cnt;     
reg [3:0] row_int_prev;         

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        row_int_prev <= 4'b1111;
        row_stable <= 4'b1110;  
        row_debounce_cnt <= 0;
    end else begin
        if (row_int == row_int_prev) begin
            if (row_debounce_cnt < 8'd9) begin
                row_debounce_cnt <= row_debounce_cnt + 1;
            end else begin
                row_stable <= row_int;  
            end
        end else begin
            row_debounce_cnt <= 0;  
        end
        row_int_prev <= row_int;  
    end
end

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        scan_key <= 15;             
    end else begin
        if (restart) begin
            sign <= 0;              
            scan_key <= 15;          
        end else begin
            case (row_int)          
                4'b1110: begin
                    case (column_debounce)
                        4'b1110: begin sign <= 1; scan_key <= 0; end
                        4'b1101: begin sign <= 1; scan_key <= 1; end
                        4'b1011: begin sign <= 1; scan_key <= 2; end
                        4'b0111: begin sign <= 1; scan_key <= 3; end
                    endcase
                end
                4'b1101: begin
                    case (column_debounce)
                        4'b1110: begin sign <= 1; scan_key <= 4; end
                        4'b1101: begin sign <= 1; scan_key <= 5; end
                        4'b1011: begin sign <= 1; scan_key <= 6; end
                        4'b0111: begin sign <= 1; scan_key <= 7; end
                    endcase
                end
                4'b1011: begin
                    case (column_debounce)
                        4'b1110: begin sign <= 1; scan_key <= 8; end
                        4'b1101: begin sign <= 1; scan_key <= 9; end
                        4'b1011: begin sign <= 1; scan_key <= 10; end
                        4'b0111: begin sign <= 1; scan_key <= 11; end
                    endcase
                end
                4'b0111: begin
                    case (column_debounce)
                        4'b1110: begin sign <= 1; scan_key <= 12; end
                        4'b1101: begin sign <= 1; scan_key <= 13; end
                        4'b1011: begin sign <= 1; scan_key <= 14; end
                        4'b0111: begin sign <= 1; scan_key <= 15; end
                    endcase
                end
                default: begin
                    scan_key <= 15;  
                end
            endcase
        end
    end
end

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        row_out <= 4'b1111;
    end else begin
        row_out <= row_stable;  
    end
end

endmodule
