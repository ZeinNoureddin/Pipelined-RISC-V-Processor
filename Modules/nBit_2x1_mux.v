`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2023 11:56:33 AM
// Design Name: 
// Module Name: nBit_2x1_mux
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

module nBit_2x1_mux#(parameter N = 8) (
    input [N-1:0] A,
    input [N-1:0] B,
    input  sel,
    output [N-1:0] Y  
 );
    
genvar i;
  
generate

    for(i = 0; i < N; i = i + 1) begin
    
        mux mux_i(
            .A(A[i]),
            .B(B[i]),
            .sel(sel),
            .Y(Y[i])
        );
    end 
    
endgenerate 
    
endmodule