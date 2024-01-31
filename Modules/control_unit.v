`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2023 01:36:56 PM
// Design Name: 
// Module Name: control_unit
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


module ControlUnit(
    
    input [31:0] allInst,
    output reg Branch,
    output reg Jump, 
    output reg MemRead, 
    output reg MemtoReg,
    output reg [2:0] ALUOp, 
    output reg MemWrite, 
    output reg ALUSrc, 
    output reg RegWrite,
    output reg [1:0] RegFileMuxSel,
    output reg PCMuxSel1
);

wire [4:0] inst;
assign inst = allInst[6:2];

//initial begin
//     Branch = 0; 
//    Jump = 0; 
//    MemRead = 1'd0; 
//    MemtoReg = 0; 
//    ALUOp = 3'b000;
//    MemWrite = 0; 
//    ALUSrc = 0; 
//    RegWrite = 0; 
//    RegFileMuxSel = 2'b00; 
//    PCMuxSel1 = 0;
//end

always@(*) begin
    case(inst)
    
        5'b01100: begin // R-Format
             if(allInst[31:25] == 7'b0000001) begin // mul / div
                Branch = 0;            
                Jump = 0;              
                MemRead = 0;           
                MemtoReg = 0;          
                ALUOp = 3'b111;        
                MemWrite = 0;          
                ALUSrc = 0;            
                RegWrite = 1;          
                RegFileMuxSel = 2'b00; 
                PCMuxSel1 = 0;              
             end
             else begin
                Branch = 0;
                Jump = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 3'b010;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 1;
                RegFileMuxSel = 2'b00; 
                PCMuxSel1 = 0;  
             end
        end
            
        5'b00100: begin // I-Format 
             Branch = 0; 
             Jump = 0;
             MemRead = 0;
             MemtoReg = 0;
             ALUOp = 3'b110;
             MemWrite = 0;
             ALUSrc = 1;
             RegWrite = 1;
             RegFileMuxSel = 2'b00;
             PCMuxSel1 = 0; 
         end
            
        5'b00000: begin // LW: 00000
             Branch = 0;
             Jump = 0;
             MemRead = 1;
             MemtoReg = 1;
             ALUOp = 3'b000;
             MemWrite = 0;
             ALUSrc = 1;
             RegWrite = 1;
             RegFileMuxSel = 2'b00; 
             PCMuxSel1 = 0;  
        end
            
        5'b01000: begin // SW: 01000
             Branch = 0;
             Jump = 0;
             MemRead = 0;
             MemtoReg = 0;
             ALUOp = 3'b000;
             MemWrite = 1;
             ALUSrc = 1;
             RegWrite = 0;
             RegFileMuxSel = 2'b00;
             PCMuxSel1 = 0;   
        end
        
        5'b11000: begin // B-Format 
             Branch = 1;
             Jump = 0; 
             MemRead = 0;
             MemtoReg = 0;
             ALUOp = 3'b001;
             MemWrite = 0;
             ALUSrc = 0;
             RegWrite = 0;
             RegFileMuxSel = 2'b00; 
             PCMuxSel1 = 0; 
        end
        
        5'b01101: begin // LUI
             Branch = 0;
             Jump = 0; 
             MemRead = 0;
             MemtoReg = 0;
             ALUOp = 3'b011;
             MemWrite = 0;
             ALUSrc = 1;
             RegWrite = 1;
             RegFileMuxSel = 2'b00;
             PCMuxSel1 = 0; 
        end
        
        5'b11011: begin // JAL
            Branch = 0; 
            Jump = 1; 
            MemRead = 0; 
            MemtoReg = 0; 
            ALUOp = 3'b011;
            MemWrite = 0; 
            ALUSrc = 1;
            RegWrite = 1; 
            RegFileMuxSel = 2'b01;
            PCMuxSel1 = 0;  
         end
        
        5'b11001: begin // JALR
            Branch = 0; 
            Jump = 1; 
            MemRead = 0; 
            MemtoReg = 0; 
            ALUOp = 3'b000;
            MemWrite = 0; 
            ALUSrc = 1; 
            RegWrite = 1; 
            RegFileMuxSel = 2'b01; 
            PCMuxSel1 = 1;
        end
        
        5'b00101: begin // AUIPC
            Branch = 0; 
            Jump = 0; 
            MemRead = 0; 
            MemtoReg = 0; 
            ALUOp = 3'b000;
            MemWrite = 0; 
            ALUSrc = 1; 
            RegWrite = 1; 
            RegFileMuxSel = 2'b10; 
            PCMuxSel1 = 0;
        end
        
        5'b00011 : begin   // FENCE
            Branch = 0; 
            Jump = 0; 
            MemRead = 0; 
            MemtoReg = 0; 
            ALUOp = 3'b011;
            MemWrite = 0; 
            ALUSrc = 0; 
            RegWrite = 0; 
            RegFileMuxSel = 2'b00; 
            PCMuxSel1 = 0;
        end
        
        5'b11100 : begin 
            if (allInst[20] == 0) begin // ECALL
                Branch = 0; 
                Jump = 0; 
                MemRead = 0; 
                MemtoReg = 0; 
                ALUOp = 3'b011;
                MemWrite = 0; 
                ALUSrc = 0; 
                RegWrite = 0; 
                RegFileMuxSel = 2'b00; 
                PCMuxSel1 = 0;
            end
            
            else begin  // EBREAK
                Branch = 0; 
                Jump = 0; 
                MemRead = 0; 
                MemtoReg = 0; 
                ALUOp = 3'b011;
                MemWrite = 0; 
                ALUSrc = 0; 
                RegWrite = 0; 
                RegFileMuxSel = 2'b00; 
                PCMuxSel1 = 1;
            end
        end
        default: begin 
         Branch = 0; 
                Jump = 0; 
                MemRead = 1'd0; 
                MemtoReg = 0; 
                ALUOp = 3'b000;
                MemWrite = 0; 
                ALUSrc = 0; 
                RegWrite = 0; 
                RegFileMuxSel = 2'b00; 
                PCMuxSel1 = 0;
           end
    endcase 
end



endmodule
