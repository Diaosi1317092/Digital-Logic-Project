`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/29 22:00:50
// Design Name: 
// Module Name: timer
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/29 22:00:50
// Design Name: 
// Module Name: timer
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
module timer (
    input clk,
    input reset,
    output [17:0] current_time
);
    reg [5:0] sec;
    reg [5:0] min;
    reg [5:0] hour;
    assign current_time={hour,min,sec};
    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            sec <= 0;
            min <= 0;
            hour <= 0;
        end else begin
            if (sec == 59) begin
                sec <= 0;
                if (min == 59) begin
                    min <= 0;
                    if (hour == 23) begin
                        hour <= 0;
                    end else begin
                        hour <= hour + 1;
                    end
                end else begin
                    min <= min + 1;
                end
            end else begin
                sec <= sec + 1;
            end
        end
    end
endmodule
