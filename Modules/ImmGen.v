`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2023 12:44:45 PM
// Design Name: 
// Module Name: ImmGen
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


module ImmGen(
    input [31:0] inst,
    output [31:0] gen_out
    );

    reg [6:0] opcode;
    
    reg [11:0] imm; 
    
    always@(inst)begin
    
        opcode = inst[6:0];
        if(opcode[6] == 0) begin
        
            if(opcode[5] == 0) begin
                // LW
                imm = inst[31:20];
            end
            
            else begin
                // SW
                imm = {inst[31:25], inst[11:7]};
            end
        end
        
        else begin
            // SB 
            imm = {inst[31], inst[7], inst[30:25], inst[11:8]};   
        end
        
    end
    
    assign gen_out = {{20{imm[11]}}, imm};
    
endmodule
