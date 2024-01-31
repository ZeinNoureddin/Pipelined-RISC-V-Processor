`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2023 12:19:44 PM
// Design Name: 
// Module Name: processor_tb
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


module processor_tb();

    localparam clk_period = 20;
    reg clk;         
    reg rst;         
    reg [1:0] ledSel;
    reg [3:0] ssdSel;
    wire [15:0] LEDs;
    wire [12:0] SSD;
    
    
    initial begin 
        clk = 1'b0;
        forever #(clk_period/2) clk = ~clk; 
    end
    
    initial begin
    
        rst = 1;
        #20;
        rst = 0;
        #2500;
//        ledSel =2'b00;
//        ssdSel = 4'b0000;
//        #20;
//        ssdSel = 4'b0001;
//        #20;
//        ssdSel = 4'b0010;
//        #20;
//        ssdSel = 4'b0011;
//        #20;
//        ssdSel = 4'b0100;
//        #20;
//        ssdSel = 4'b0101;
//        #20;
//        ssdSel = 4'b0110;
//        #20;
//        ssdSel = 4'b0111;
//        #20;
//        ssdSel = 4'b1000;
//        #20;
//        ssdSel = 4'b1001;
//        #20;
//        ssdSel = 4'b1010;
//        #20;
//        ssdSel = 4'b1011;
//        #20;
//        ledSel = 2'b00;
//        #20;
//        ledSel = 2'b01;
//        #20;
//        ledSel = 2'b10;
//        #20;
        $finish;
    end
    
    
    processor processor_inst(
        .clk(clk),
        .rst(rst),
        .ledSel(ledSel),
        .ssdSel(ssdSel),
        .LEDs(LEDs),
        .SSD(SSD)
    );    
    
  
endmodule
