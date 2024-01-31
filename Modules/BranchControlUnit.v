`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2023 05:21:34 PM
// Design Name: 
// Module Name: BranchControlUnit
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
`include "defines.v"

module BranchControlUnit(
    input [2:0] funct3, 
    input zf, sf, vf, cf,
    input branch,
    input jump,
    output reg branchCUOut
);
    
    always@(*) begin
        if(branch) begin
            case(funct3)
                `BR_BEQ: branchCUOut = zf; 
                `BR_BNE: branchCUOut = ~zf; 
                `BR_BLT: branchCUOut = (sf != vf);
                `BR_BGE: branchCUOut = (sf == vf);
                `BR_BLTU: branchCUOut = ~cf;
                `BR_BGEU: branchCUOut = cf; 
                default: branchCUOut = 1'b0; 
            endcase
        end
        
        else if (jump) branchCUOut = 1'b1; 
        else branchCUOut = 1'b0; 
    end
    
endmodule
