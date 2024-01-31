`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2023 10:58:36 AM
// Design Name: 
// Module Name: N_Bit_ALU
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


module N_Bit_ALU#(parameter N = 32) (
    input [N-1:0] A,
    input [N-1:0] B,
    input [3:0] sel,
    output reg [N-1:0] ALUOutput,
    output reg zeroFlag
    );
    wire [N-1:0] rca_out;
    wire [N-1:0] B_in; 
    assign B_in = (sel == 4'b0110) ?  ~ B + 1 :  B; 
    
    rca#(.N(N))rca_inst(
            .a(A),
            .b(B_in),
            .sum(rca_out)
        );
    
    always@(*) begin
        case(sel)
            4'b0010: ALUOutput = rca_out; 
            4'b0110: ALUOutput = rca_out; 
            4'b0000: ALUOutput = A & B;
            4'b0001: ALUOutput = A | B; 
            default: ALUOutput = 0; 
         endcase
         
         if(ALUOutput == 0) zeroFlag = 1'b1; 
         else zeroFlag = 1'b0;
    end

endmodule
