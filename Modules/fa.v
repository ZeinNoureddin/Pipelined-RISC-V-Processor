`timescale 1ns / 1ps

module FA(
    input a, b, cin,
    output s, cout
    );
    
    assign {cout, s} = a + b + cin; 
    
endmodule
