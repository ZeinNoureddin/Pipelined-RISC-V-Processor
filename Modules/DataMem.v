`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2023 12:22:42 PM
// Design Name: 
// Module Name: DataMem
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

module DataMem(
    input clk, 
    input MemRead,
    input MemWrite,
    input [12:0] addr,
    input [31:0] data_in,
    input [2:0] funct3,
    output reg [31:0] data_out
);
    reg [7:0] mem [399 : 0];   // small for easy debugging
    // reg [7:0] mem [(4*1024)-1 : 0];
    
    wire [12:0] dataOffset = 12'd199;  // half for instructions, half for data. 
    wire [12:0] dataAddress;
    assign dataAddress = dataOffset + addr;
    
    always@(posedge clk)begin
        if (MemWrite == 1)begin
           case(funct3)
               3'b000 : mem[dataAddress] = data_in[7:0]; // SB
               3'b001 : {mem[dataAddress+1], mem[dataAddress]} = data_in[15:0]; // SH
               3'b010 : {mem[dataAddress+3], mem[dataAddress+2], mem[dataAddress+1], mem[dataAddress]} = data_in; // SW
           endcase
        end
    end
    
    always@(*) begin
       if (!clk) begin
           if(MemRead == 1) begin
               case(funct3)
                   3'b000 : data_out = $signed(mem[dataAddress]); // LB
                   3'b001 : data_out = $signed({mem[dataAddress+1], mem[dataAddress]}); // LH
                   3'b010 : data_out = $signed({mem[dataAddress+3], mem[dataAddress+2], mem[dataAddress+1], mem[dataAddress]}); // LW
                   3'b100 : data_out = mem[dataAddress]; // LBU
                   3'b101 : data_out = {mem[dataAddress+1], mem[dataAddress]}; // LHU
               endcase
           end
        end
       else data_out={mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]}; // output is an instruction
    end
    
     // Memory initialization
    integer i;
    
    initial begin   
        for(i = 0; i < 400; i = i+1)begin
           mem[i] = 8'd0;
        end
    end
    
    initial begin 
//       {mem[3], mem[2], mem[1], mem[0]}     = 32'b000000000000_00000_010_00001_0000011 ; //lw x1, 0(x0)
//       {mem[7], mem[6], mem[5], mem[4]}     = 32'b000000000100_00000_010_00010_0000011 ; //lw x2, 4(x0)
//       {mem[11], mem[10], mem[9], mem[8]}   = 32'b000000001000_00000_010_00011_0000011 ; //lw x3, 8(x0)
//       {mem[15], mem[14], mem[13], mem[12]} = 32'b0000000_00010_00001_110_00100_0110011 ; //or x4, x1, x2
//       {mem[19], mem[18], mem[17], mem[16]} = 32'b00000000001100100000010001100011; //beq x4, x3, 4
//       {mem[23], mem[22], mem[21], mem[20]} = 32'b0000000_00010_00001_000_00011_0110011 ; //add x3, x1, x2        
//       {mem[27], mem[26], mem[25], mem[24]} = 32'b0000000_00010_00011_000_00101_0110011 ; //add x5, x3, x2
//       {mem[31], mem[30], mem[29], mem[28]} = 32'b0000000_00101_00000_010_01100_0100011; //sw x5, 12(x0)
//       {mem[35], mem[34], mem[33], mem[32]} = 32'b000000001100_00000_010_00110_0000011 ; //lw x6, 12(x0)
//       {mem[39], mem[38], mem[37], mem[36]} = 32'b0000000_00001_00110_111_00111_0110011 ; //and x7, x6, x1
//       {mem[43], mem[42], mem[41], mem[40]} = 32'b0100000_00010_00001_000_01000_0110011 ; //sub x8, x1, x2
//       {mem[47], mem[46], mem[45], mem[44]} = 32'b0000000_00010_00001_000_00000_0110011 ; //add x0, x1, x2
//       {mem[51], mem[50], mem[49], mem[48]} = 32'b0000000_00001_00000_000_01001_0110011 ; //add 9, x0, addr     


    {mem[3], mem[2], mem[1], mem[0]}         =        32'b00000000000000001001010100010111; // auipc x10, 9    
    {mem[7], mem[6], mem[5], mem[4]}         =        32'b00000000000000001001010010110111; // lui x9, 9       
    {mem[11], mem[10], mem[9], mem[8]}       =        32'b00000000010001010000010110010011; // addi x11, x10, 4
    {mem[15], mem[14], mem[13], mem[12]}     =        32'b00000000000001010000011000110011; //add x12, x10, x0 
    {mem[19], mem[18], mem[17], mem[16]}     =        32'b00000000100000000000000011101111; //jal ra,8         
    {mem[23], mem[22], mem[21], mem[20]}     =        32'b00000000000000000000000000001111; // fence           
    {mem[27], mem[26], mem[25], mem[24]}     =        32'b00001000101101010000110001100011; //beq x10, x11, 152
    {mem[31], mem[30], mem[29], mem[28]}     =        32'b00000000101101010001010001100011 ;//bne x10, x11, 8      
    {mem[35], mem[34], mem[33], mem[32]}     =        32'b00000000000000000000000001110011; // ecall               
    {mem[39], mem[38], mem[37], mem[36]}     =        32'b00000011001000000000001100010011; //addi x6, x0, 50      
    {mem[43], mem[42], mem[41], mem[40]}     =        32'b00000000001000110001001100010011; //slli x6, x6, 2       
    {mem[47], mem[46], mem[45], mem[44]}     =        32'b00000000001000000000001110010011 ; //addi x7, x0, 2      
    {mem[51], mem[50], mem[49], mem[48]}     =        32'b00000000011100000000000000100011;//sb x7, 0(x0)          
    {mem[55], mem[54], mem[53], mem[52]}     =        32'b00000000101000000001000000100011; //sh x10, 0(x0)        
    {mem[59], mem[58], mem[57], mem[56]}     =        32'b00000000101000000010000000100011; // sw x10, 0(x0)       
    {mem[63], mem[62], mem[61], mem[60]}     =        32'b00000000000000000000111000000011; // lb x28, 0(x0)       
    {mem[67], mem[66], mem[65], mem[64]}     =        32'b00000000000000000001111010000011;//lh x29, 0(x0)         
    {mem[71], mem[70], mem[69], mem[68]}     =        32'b00000000000000000010111100000011; //lw x30, 0(x0)        
    {mem[75], mem[74], mem[73], mem[72]}     =        32'b00000000000000000100111110000011; //lbu x31, 0(x0)       
    {mem[79], mem[78], mem[77], mem[76]}     =        32'b00000000000000000101001100000011; //lhu x6, 0(x0)        
    {mem[83], mem[82], mem[81], mem[80]}     =        32'b00000110101101100101000001100011; // bge x12, x11, 96    
    {mem[87], mem[86], mem[85], mem[84]}     =        32'b00000100110001011100111001100011; //blt x11, x12, 92     
    {mem[91], mem[90], mem[89], mem[88]}     =        32'b00000100101101100111110001100011; //bgeu x12, x11, 88    
    {mem[95], mem[94], mem[93], mem[92]}     =        32'b00000100110001011110101001100011; //bltu x11, x12, 84    
    {mem[99], mem[98], mem[97], mem[96]}     =        32'b11111001110001100011001100010011; //sltiu x6, x12, -100  
    {mem[103], mem[102], mem[101], mem[100]} =        32'b00000000001100110100111000010011; //xori x28, x6, 3      
    {mem[107], mem[106], mem[105], mem[104]} =        32'b00000000010111100110111000010011; //ori x28, x28, 5      
    {mem[111], mem[110], mem[109], mem[108]} =        32'b00000000010111100111111000010011; //andi x28, x28, 5     
    {mem[115], mem[114], mem[113], mem[112]} =        32'b00000000000111100101111000010011; //srli x28, x28, 1     
    {mem[119], mem[118], mem[117], mem[116]} =        32'b00000010100011100000111000010011; //addi x28, x28, 40    
    {mem[123], mem[122], mem[121], mem[120]} =        32'b01000000001011100101111000010011; //srai x28, x28, 2     
    {mem[127], mem[126], mem[125], mem[124]} =        32'b00000000001100000000001110010011; //addi x7, x0, 3       
    {mem[131], mem[130], mem[129], mem[128]} =        32'b01000000011111100000111000110011; // sub x28, x28, x7    
    {mem[135], mem[134], mem[133], mem[132]} =        32'b00000001110011100001111000110011; //sll x28, x28, x28    
    {mem[139], mem[138], mem[137], mem[136]} =        32'b00000001110011100010111100110011; //slt x30, x28, x28    
    {mem[143], mem[142], mem[141], mem[140]} =        32'b00000000011000000000111010010011; //addi x29, x0, 6      
    {mem[147], mem[146], mem[145], mem[144]} =        32'b00000001110011101011111100110011; //sltu x30, x29, x28   
    {mem[151], mem[150], mem[149], mem[148]} =        32'b00000001110111110100111100110011; //xor x30, x30, x29    
    {mem[155], mem[154], mem[153], mem[152]} =        32'b00000000010011110001111100010011; //slli x30, x30, 4     
    {mem[159], mem[158], mem[157], mem[156]} =        32'b00000000011111110101111100110011; //srl x30, x30, x7     
    {mem[163], mem[162], mem[161], mem[160]} =        32'b01000000011111110101111100110011; //sra x30, x30, x7     
    {mem[167], mem[166], mem[165], mem[164]} =        32'b00000000011111110110111100110011; //or x30, x30, x7      
    {mem[171], mem[170], mem[169], mem[168]} =        32'b00000001110111110111111100110011; //and x30, x30, x29    
    {mem[175], mem[174], mem[173], mem[172]} =        32'b00000000000100000000000001110011;// ebreak               
    {mem[179], mem[178], mem[177], mem[176]} =        32'b00000000000000001000000001100111; // jalr x0, 0(x1)      
//    {mem[183], mem[182], mem[181], mem[180]} =              
//    {mem[187], mem[186], mem[185], mem[184]} =              
//    {mem[191], mem[190], mem[189], mem[188]} =              
//    {mem[195], mem[194], mem[193], mem[192]} =              
//    {mem[199], mem[198], mem[197], mem[196]} =              

//        $readmemh("C:/Users/zein30ne/Desktop/test cases/test3layla.hex", mem);
        $display("%d", mem[0]);
        mem[dataOffset] = 8'd17;
        mem[dataOffset+4] = 8'd9;
        mem[dataOffset+8] = 8'd25;
        
    end
    
endmodule

//     mem[3] = 8'b1;
       
       
//     mem[0]=32'd9622227;
//     mem[0]=8'd17;
//     mem[4]=8'd9;
//     mem[8]=8'd25;
         
//    mem[3] = 32'b1;
//    mem[0]=32'd0;
//    mem[1]=32'd1;
//    mem[2]=32'd4;

