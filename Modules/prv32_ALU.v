`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2023 05:55:47 PM
// Design Name: 
// Module Name: prv32_ALU
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


module prv32_ALU(
	input   wire [31:0] a, b,
	input   wire [4:0]  shamt,
	output  reg  [31:0] r,
	output  wire        cf, zf, vf, sf,
	input   wire [4:0]  alufn
);

    wire [31:0] add, sub, op_b;
    wire cfa, cfs;
    
    assign op_b = (~b);
    
    assign {cf, add} = alufn[0] ? (a + op_b + 1'b1) : (a + b);
    
    assign zf = (add == 0);
    assign sf = add[31];
    assign vf = (a[31] ^ (op_b[31]) ^ add[31] ^ cf);
    
    wire[31:0] sh;
    shifter shifter0(.a(a), .shamt(shamt), .type(alufn[1:0]),  .r(sh));
    
    wire [63:0] a_signed, b_signed; 
    assign a_signed = $signed(a); 
    assign b_signed = $signed(b); 
    wire [63:0] as_by_bs, as_by_bus, aus_by_bus; 
    assign as_by_bs = a_signed * b_signed; 
    assign as_by_bus = a_signed * {32'b0, b};
    assign aus_by_bus = {32'b0, a} * {32'b0, b}; 
    
    
    always @ * begin
        r = 0;
        (* parallel_case *)
        case (alufn)
            // arithmetic
            5'b00_00 : r = add;
            5'b00_01 : r = add;
            5'b00_11 : r = b;
            // logic
            5'b01_00:  r = a | b;
            5'b01_01:  r = a & b;
            5'b01_11:  r = a ^ b;
            // shift
            5'b10_00:  r=sh;
            5'b10_01:  r=sh;
            5'b10_10:  r=sh;
            // slt & sltu
            5'b11_01:  r = {31'b0,(sf != vf)}; 
            5'b11_11:  r = {31'b0,(~cf)};   
            // mul & div
            5'b100_00: r = a*b;                // mul
            5'b100_01: r = $signed(a)/$signed(b);  // div
            5'b100_10: r = as_by_bs[63:32];    // mulh 
            5'b100_11: r = as_by_bus[63:32];   // mulhsu
            5'b101_00: r = aus_by_bus[63:32];  // mulhu
            
                  	
        endcase
    end
endmodule
