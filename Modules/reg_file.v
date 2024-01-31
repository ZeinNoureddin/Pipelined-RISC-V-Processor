`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2023 12:19:12 PM
// Design Name: 
// Module Name: reg_file
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

module RegFile#(parameter n = 32 , m = 5 )(
    input clk,
    input rst,
    input [m-1:0] readReg1,
    input [m-1:0] readReg2,
    input [m-1:0] writeReg,
    input [n-1:0] writeData, 
    input regWrite,
    output [n-1:0] readData1,
    output [n-1:0] readData2
);
    reg [n-1:0] reg_file[n-1:0];
    integer j;
    always@(negedge(clk)) begin
        if(rst==1'b1) begin
            for(j = 0; j < 32; j = j + 1) begin
                reg_file[j] <= 0;
            end
        end
        else begin
            if(regWrite == 1'b1 && writeReg != 1'b0) reg_file[writeReg] <= writeData; 
        end
     end
     assign readData1 = reg_file[readReg1];
     assign readData2 = reg_file[readReg2];

endmodule
