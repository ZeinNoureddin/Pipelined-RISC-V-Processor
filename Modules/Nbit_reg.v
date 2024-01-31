`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2023 11:09:40 AM
// Design Name: 
// Module Name: Nbit_reg
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


module Nbit_reg#(parameter N = 32)(
    input clk,
    input rst, 
    input load, 
    input [N-1:0] D,
    output [N-1:0] Q
    );
    
    wire [N-1:0] Y;
    
    genvar i; 
    generate
        for(i = 0; i < N; i = i + 1) begin
        
            mux mux_i(
                .A(Q[i]),
                .B(D[i]),
                .sel(load),
                .Y(Y[i])
            );
            
            DFlipFlop dff(
                .clk(clk), 
                .rst(rst), 
                .D(Y[i]),
                .Q(Q[i])
            );
        end
    endgenerate
endmodule
