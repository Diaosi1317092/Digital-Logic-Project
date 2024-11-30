`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/29 21:50:36
// Design Name: 
// Module Name: top_module
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

module top_module (
    input clk,
    input reset,
    output [7:0] seg1,
    output [7:0] seg2,
    output wire [5:0] an
);

    wire clk_out;
    wire clk_out_en;
    wire [5:0] sec;
    wire [5:0] min;
    wire [5:0] hour;
    reg [3:0] select;
    reg [1:0] cycle_count;

    clock_divider clk_div_inst (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_out)
    );
    
    clock_divider_enable clk_en_inst (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_out_en)
    );

    timer timer_inst (
        .clk(clk_out),
        .reset(reset),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    seven_segment_display display_inst (
        .sec(sec),
        .min(min),
        .hour(hour),
        .select(select),
        .seg1(seg1),
        .seg2(seg2),
        .an(an)
    );

    always @(posedge clk_out_en or posedge reset) begin
        if (~reset) begin
            select <= 4'd0;
        end else begin
            if (select == 4'd5) begin 
                select <= 4'd0;
            end
            else begin
                select <= select + 1;
            end
        end
    end

    assign an = (select == 4'd0) ? 6'b100000 :
                (select == 4'd1) ? 6'b010000 :
                (select == 4'd2) ? 6'b001000 :
                (select == 4'd3) ? 6'b000100 : 
                (select == 4'd4) ? 6'b000010 : 
                (select == 4'd5) ? 6'b000001 : 6'b111111;

endmodule




