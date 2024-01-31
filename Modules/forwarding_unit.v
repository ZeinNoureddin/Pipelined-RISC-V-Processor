`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2023 03:29:23 PM
// Design Name: 
// Module Name: forwarding_unit
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


module forwardingUnit(
    input [4:0] ID_EX_rs1, ID_EX_rs2, EX_MEM_rd, MEM_WB_rd,
    input EX_MEM_RegWrite, MEM_WB_RegWrite,
    output reg [1:0] forward_A, forward_B
);

    always@(*) begin
    
        forward_A = 2'b00;
        forward_B = 2'b00;
        
        // Execution Hazard
        if(EX_MEM_RegWrite == 1'b1 && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs1) begin
            forward_A = 2'b10; 
        end
        
        if(EX_MEM_RegWrite == 1'b1 && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs2) begin
            forward_B = 2'b10; 
        end
        
        
        // Memory Hazard
        if(MEM_WB_RegWrite == 1'b1 && MEM_WB_rd != 0 && MEM_WB_rd == ID_EX_rs1
         && !(EX_MEM_RegWrite == 1'b1 && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs1)) begin
            forward_A = 2'b01; 
        end
        
        if(MEM_WB_RegWrite == 1'b1 && MEM_WB_rd != 0 && MEM_WB_rd == ID_EX_rs2
         && !(EX_MEM_RegWrite == 1'b1 && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs2)) begin
            forward_B = 2'b01; 
        end
        
        
    end
endmodule
