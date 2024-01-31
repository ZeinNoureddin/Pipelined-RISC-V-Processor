`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2023 03:31:39 PM
// Design Name: 
// Module Name: hazard_detection_unit
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


module hazardDetectionUnit(
    input [4:0] IF_ID_rs1, IF_ID_rs2, ID_EX_rd,
    input ID_EX_MemRead,
    output reg stall
);

    always @(*) begin
    
        stall = 1'b0;
        if( (IF_ID_rs1 == ID_EX_rd || IF_ID_rs2 == ID_EX_rd) && ID_EX_MemRead == 1'b1 && ID_EX_rd != 0)
            stall = 1'b1;
            
    end

endmodule

