`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2023 11:20:44 AM
// Design Name: 
// Module Name: rca
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


module rca#(N = 32)(
    input [N - 1:0]a, [N - 1:0]b,
    output [N:0]sum
    );
    wire [N:0] w;
    assign w[0] = 0; 
    assign sum[N] = w[N];
    
    genvar i;
    
    generate 
        for(i = 0; i < N; i = i + 1) begin
            FA fat(a[i], b[i], w[i], sum[i], w[i + 1]);
        end
    endgenerate
    
endmodule
