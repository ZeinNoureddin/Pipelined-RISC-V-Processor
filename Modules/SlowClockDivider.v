`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2023 11:44:40 PM
// Design Name: 
// Module Name: SlowClockDivider
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


module SlowClockDivider(input clk, rst, output reg sclk);

initial begin
    sclk = 0;
end

always@ (posedge clk) begin
    sclk = !sclk;
end

endmodule
