`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2023 01:38:28 PM
// Design Name: 
// Module Name: top
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


module top(
    input clk, 
    input SSD_clk,
    input rst,
    input [1:0] ledSel,
    input [3:0] ssdSel,
    output [15:0] LEDs,
    output wire [3:0] Anode,
    output wire [6:0] LED_out
);

    // SSD wire
    wire [12:0] SSD;
    
    
    // Processor
    processor processor_inst(
        .clk(clk), 
        .rst(rst),
        .ledSel(ledSel),
        .ssdSel(ssdSel),
        .LEDs(LEDs),
        .SSD(SSD)
    );


    // FDSSD 
    FDSSD fdssd(
       .clk(SSD_clk),
       .num(SSD),
       .Anode(Anode),
       .LED_out(LED_out)
    );


endmodule
