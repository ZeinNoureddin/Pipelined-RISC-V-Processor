`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2023 02:07:49 PM
// Design Name: 
// Module Name: ALU_control_unit
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


module ALUControlUnit(
    input [2:0] ALUOp,
    input [31:0] inst,
    output reg [4:0] ALUSelection
);
    
    wire [6:0] concat = {ALUOp, inst[14:12], inst[30]};
    always@(*)begin
        // load and branch
        if (ALUOp == 3'b000) ALUSelection = `ALU_ADD; 
        else if (ALUOp == 3'b001) ALUSelection = `ALU_SUB;
        else if (ALUOp == 3'b011) ALUSelection = `ALU_PASS;


        else if (ALUOp == 3'b010 && inst[14:12] == 3'b000 && inst[30] == 1'b0) ALUSelection = `ALU_ADD;
        else if (ALUOp == 3'b010 && inst[14:12] == 3'b000 && inst[30] == 1'b1) ALUSelection = `ALU_SUB;
        else if (ALUOp == 3'b010 && inst[14:12] == 3'b111 && inst[30] == 1'b0) ALUSelection = `ALU_AND;
        else if (ALUOp == 3'b010 && inst[14:12] == 3'b110 && inst[30] == 1'b0) ALUSelection = `ALU_OR;
        else if (ALUOp == 3'b010 && inst[14:12] == 3'b100 && inst[30] == 1'b0) ALUSelection = `ALU_XOR;
        else if (ALUOp == 3'b010 && inst[14:12] == 3'b001 && inst[30] == 1'b0) ALUSelection = `ALU_SLL;
        else if (ALUOp == 3'b010 && inst[14:12] == 3'b101 && inst[30] == 1'b0) ALUSelection = `ALU_SRL;
        else if (ALUOp == 3'b010 && inst[14:12] == 3'b101 && inst[30] == 1'b1) ALUSelection = `ALU_SRA;
        else if (ALUOp == 3'b010 && inst[14:12] == 3'b010 && inst[30] == 1'b0) ALUSelection = `ALU_SLT;
        else if (ALUOp == 3'b010 && inst[14:12] == 3'b011 && inst[30] == 1'b0) ALUSelection = `ALU_SLTU;
                          
        else if (ALUOp == 3'b110 && inst[14:12] == 3'b000) ALUSelection = `ALU_ADD;
        else if (ALUOp == 3'b110 && inst[14:12] == 3'b111) ALUSelection = `ALU_AND;
        else if (ALUOp == 3'b110 && inst[14:12] == 3'b110) ALUSelection = `ALU_OR;
        else if (ALUOp == 3'b110 && inst[14:12] == 3'b100) ALUSelection = `ALU_XOR;
        else if (ALUOp == 3'b110 && inst[14:12] == 3'b010) ALUSelection = `ALU_SLT;
        else if (ALUOp == 3'b110 && inst[14:12] == 3'b011) ALUSelection = `ALU_SLTU;
        else if (ALUOp == 3'b110 && inst[14:12] == 3'b001) ALUSelection = `ALU_SLL;
        else if (ALUOp == 3'b110 && inst[14:12] == 3'b101 && inst[30] == 1'b0) ALUSelection = `ALU_SRL;
        else if (ALUOp == 3'b110 && inst[14:12] == 3'b101 && inst[30] == 1'b1) ALUSelection = `ALU_SRA;
        
        else if (ALUOp == 3'b111 && inst[14:12] == 3'b000) ALUSelection = `ALU_MUL;
        else if (ALUOp == 3'b111 && inst[14:12] == 3'b100) ALUSelection = `ALU_DIV;
        else if (ALUOp == 3'b111 && inst[14:12] == 3'b001) ALUSelection = `ALU_MULH; 
        else if (ALUOp == 3'b111 && inst[14:12] == 3'b010) ALUSelection = `ALU_MULHSU; 
        else if (ALUOp == 3'b111 && inst[14:12] == 3'b011) ALUSelection = `ALU_MULHU; 
        

     end


endmodule
