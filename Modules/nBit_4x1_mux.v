`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2023 08:35:53 PM
// Design Name: 
// Module Name: nBit_4x1_mux
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


module nBit_4x1_mux #(parameter N = 32)(
    input [N-1:0] A, B, C, D, 
    input [1:0] sel, 
    output reg [N-1:0] Y
);

    always@(*) begin
        case(sel)
            2'b00: Y = A; 
            2'b01: Y = B; 
            2'b10: Y = C; 
            2'b11: Y = D; 
            default: Y = A; 
        endcase
    end
    
endmodule
