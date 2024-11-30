`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/30 14:37:58
// Design Name: 
// Module Name: lighting_function
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


module lighting_function(
input power,
input light_in,
output reg light_out
    );
parameter on=1'b1, off=1'b0;

    always@*
        if(power==on & light_in==on)
            light_out=on;
        else
            ligh_out=off;
            
endmodule