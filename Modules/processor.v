`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2023 12:15:42 PM
// Design Name: 
// Module Name: processor
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


module processor#(parameter n = 32 , m = 5)(
    input clk, 
    input rst,
    input [1:0] ledSel,
    input [3:0] ssdSel,
    output reg [15:0] LEDs,
    output reg [12:0] SSD
);


    wire [4:0] MEM_WB_Rd;
    wire MEM_WB_RegWrite;
    wire [31:0] data_mem_mux_out;
    wire [1:0]  MEM_WB_RegFileMuxSel; 
    wire [31:0] MEM_WB_after_shift_adder_out;
    wire [31:0] MEM_WB_PC_adder_out;
    wire [31:0] EX_MEM_PC; 
    wire EX_MEM_PC_mux_sel1;
    wire [31:0] EX_MEM_BranchAddOut;
    wire [31:0] adder_mux_out;
    wire [4:0] ID_EX_Rd;
    
    // PC
    wire [31:0] PCOutput; 
    Nbit_reg PC(
        .clk(clk),
        .rst(rst),
        .load(!(!Jump && PCMuxSel1)),  // MAKE SURE IS IT ALWAYS 1
//        .load(1'b1),
        .D(adder_mux_out),
        .Q(PCOutput)
    );
    
    // MUX After Adder
     nBit_4x1_mux #(.N(32)) adder_mux(
        .A(PC_adder_out),
        .B(EX_MEM_BranchAddOut),
        .C(EX_MEM_PC),  // CHECK IF YOU'RE PASSING FROM CORRECT STAGE
        .D(EX_MEM_ALU_out), // CHECK IF YOU'RE PASSING FROM CORRECT STAGE
        .sel({EX_MEM_PC_mux_sel1, branchUnitOut}), // CHECK IF YOU'RE PASSING FROM CORRECT STAGE
        .Y(adder_mux_out)
     );
    
     // PC Adder
     wire [31:0] PC_adder_out; 
     rca PC_adder(
        .a(PCOutput),
        .b(4),
        .sum(PC_adder_out)
     );
     
//    // Instruction Memory
//    wire [31:0] inst_mem_output; 
//    InstMem inst_mem(
//        .addr(PCOutput[7:2]),
//        .data_out(inst_mem_output)
//    );

    // Single Memory Mux.
    wire [12:0] AddressIn;
    nBit_2x1_mux #(13) single_mem_mux(
        .A({5'd0, EX_MEM_ALU_out[7:0]}),
        .B(PCOutput),
        .sel(clk), 
        .Y(AddressIn)
    );
    
    // THE ONE AND ONLY MEMORY.
    wire [31:0] data_mem_out; 
    DataMem data_mem(
        .clk(clk),
        .MemRead(EX_MEM_MemRead),
        .MemWrite(EX_MEM_MemWrite),
        .addr(AddressIn),
        .data_in(EX_MEM_RegR2),
        .funct3(EX_MEM_Inst[14:12]),
        .data_out(data_mem_out)
    );
    
//    // FIX HERE
//    wire [31:0] fetchFlushOut;
//    nBit_2x1_mux #(32) fetch_flush_mux(
//        .A(data_mem_out),
//        .B(32'b00000000000000000000000000110011),  // add x0, x0, x0
//        .sel(!branchUnitOut && PCMuxSel1),
//        .Y(fetchFlushOut)
//    );
    
    
    ///////////////////////////////////////////////////////////
    // IF/ID
    ///////////////////////////////////////////////////////////
    wire [31:0] IF_ID_PC, IF_ID_Inst, IF_ID_PC_adder_out;
    Nbit_reg #(96) IF_ID (!clk, rst,1'b1,
                          {PCOutput, data_mem_out, PC_adder_out},
                          {IF_ID_PC, IF_ID_Inst, IF_ID_PC_adder_out} );
    
    // Instruction Memory Output Splitting
    wire [4:0] readReg1; 
    wire [4:0] readReg2;
    wire [4:0] writeReg;
    assign readReg1 = IF_ID_Inst[19:15];
    assign readReg2 = IF_ID_Inst[24:20];
    assign writeReg  = IF_ID_Inst[11:7];
    
    // Control Unit
    wire Branch;
    wire Jump;
    wire MemRead;
    wire MemtoReg;
    wire [2:0] ALUOp; 
    wire MemWrite;
    wire ALUSrc; 
    wire RegWrite;
    wire [1:0] RegFileMuxSel;
    wire PCMuxSel1;
    ControlUnit control_unit(
        .allInst(IF_ID_Inst),
        .Branch(Branch),
        .Jump(Jump),     
        .MemRead(MemRead),    
        .MemtoReg(MemtoReg),   
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),   
        .ALUSrc(ALUSrc),     
        .RegWrite(RegWrite),
        .RegFileMuxSel(RegFileMuxSel),
        .PCMuxSel1(PCMuxSel1)
    );
    
     // MUX Before Reg File // FIX THISSSSS
     wire [31:0] pre_reg_file_mux_out; 
     nBit_4x1_mux #(.N(32)) pre_reg_file_mux(
        .A(data_mem_mux_out),
        .B(MEM_WB_PC_adder_out),
        .C(MEM_WB_after_shift_adder_out),
        .D(data_mem_mux_out),
        .sel(MEM_WB_RegFileMuxSel),
        .Y(pre_reg_file_mux_out)
     );
     
    // Register File
    wire [n-1:0] readData1;
    wire [n-1:0] readData2;
    RegFile reg_file(
        .clk(clk),
        .rst(rst),
        .readReg1(readReg1), 
        .readReg2(readReg2), 
        .writeReg(MEM_WB_Rd), 
        .writeData(pre_reg_file_mux_out),
        .regWrite(MEM_WB_RegWrite),
        .readData1(readData1),
        .readData2(readData2)
    );
    
    // Immediate Generator
    wire [31:0] gen_out;
    rv32_ImmGen imm_gen(
        .IR(IF_ID_Inst),
        .Imm(gen_out)    
    );
    
//        // Hazard Detection Unit
//    wire stall;
//    hazardDetectionUnit hazard_detection_unit(
//        .IF_ID_rs1(readReg1),
//        .IF_ID_rs2(readReg2),
//        .ID_EX_rd(ID_EX_Rd),
//        .ID_EX_MemRead(ID_EX_MemRead),
//        .stall(stall)
//    );     
    
//     wire [9:0] hazard_mux_out; 
//    nBit_2x1_mux #(.N(10)) hazard_mux(
//        .A({Branch, Jump, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite}),
//        .B(10'd0),
//        //.sel(stall || (EX_MEM_Branch && EX_MEM_Zero)),
//        .sel(stall || branchUnitOut),
//        .Y(hazard_mux_out)
//    );     
    
    
    ///////////////////////////////////////////////////////////                     
    // ID/EX
    ///////////////////////////////////////////////////////////
    wire [31:0] ID_EX_PC, ID_EX_Inst, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm;
    wire ID_EX_Branch;
    wire ID_EX_Jump; 
    wire ID_EX_MemRead;
    wire ID_EX_MemtoReg;
    wire [2:0] ID_EX_ALUOp; 
    wire ID_EX_MemWrite;
    wire ID_EX_ALUSrc; 
    wire ID_EX_RegWrite;
    wire [4:0] ID_EX_Rs1, ID_EX_Rs2;
    wire ID_EX_PC_mux_sel1; 
    wire [31:0] ID_EX_PC_adder_out;
    wire [1:0] ID_EX_RegFileMuxSel; 
    Nbit_reg #(220) ID_EX (clk, rst, 1'b1,
                           {Branch, Jump, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite,
                           IF_ID_PC, readData1, readData2, gen_out, IF_ID_Inst, readReg1, readReg2, writeReg, PCMuxSel1, IF_ID_PC_adder_out, RegFileMuxSel},
                           {ID_EX_Branch, ID_EX_Jump, ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_ALUOp, ID_EX_MemWrite, ID_EX_ALUSrc, ID_EX_RegWrite, 
                           ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm, ID_EX_Inst, ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd, ID_EX_PC_mux_sel1, ID_EX_PC_adder_out, ID_EX_RegFileMuxSel} );
    
     // Immediate Generator Shift Left
     wire [31:0] left_shifted_imm; 
     nBitShiftLeft1 n_bit_shift_left_1(
        .in(ID_EX_Imm),
        .out(left_shifted_imm)
     );  // msh fare2 el mafrood
    
    // After Shift Adder
    wire [31:0] after_shift_adder_out; 
    rca after_shift_adder(
        .a(ID_EX_PC),
        .b(ID_EX_Imm),
        .sum(after_shift_adder_out)
    );
    
    // Forwarding Unit
    wire [1:0] forward_A;
    wire [1:0] forward_B;
    forwardingUnit forwarding_unit(
        .ID_EX_rs1(ID_EX_Rs1), 
        .ID_EX_rs2(ID_EX_Rs2), 
        .EX_MEM_rd(EX_MEM_Rd), 
        .MEM_WB_rd(MEM_WB_Rd),
        .EX_MEM_RegWrite(EX_MEM_RegWrite), 
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .forward_A(forward_A), 
        .forward_B(forward_B)
    );
    
    // RegFile Forwarding A MUX
    wire [31:0] forward_A_mux_out; 
    nBit_4x1_mux #(.N(32)) forward_A_mux (
        .A(ID_EX_RegR1),
        .B(data_mem_mux_out),
        .C(EX_MEM_ALU_out),
        .D(ID_EX_RegR1), 
        .sel(forward_A), 
        .Y(forward_A_mux_out)
    );
    
    // RegFile Forwarding B MUX
    wire [31:0] forward_B_mux_out; 
    nBit_4x1_mux #(.N(32)) forward_B_mux (
        .A(ID_EX_RegR2),
        .B(data_mem_mux_out),
        .C(EX_MEM_ALU_out),
        .D(ID_EX_RegR2), 
        .sel(forward_B), 
        .Y(forward_B_mux_out)
    );
    
    // MUX After RegFile
    wire [31:0] reg_file_mux_out; 
    nBit_2x1_mux #(.N(32)) reg_file_mux(
        .A(forward_B_mux_out),
        .B(ID_EX_Imm),
        .sel(ID_EX_ALUSrc),
        .Y(reg_file_mux_out)
     );
     
     // ALU Control Unit
     wire [4:0] ALUSelection; 
     ALUControlUnit ALU_control_unit(
        .ALUOp(ID_EX_ALUOp),
        .inst(ID_EX_Inst),
        .ALUSelection(ALUSelection)
     );    
        
    // ALU After RegFile
    wire [31:0] ALUOutput; 
    wire zeroFlag, carryFlag, signFlag, overflowFlag; // PASS TO NEXT STAGE
    prv32_ALU reg_file_ALU(
        .a(forward_A_mux_out),
        .b(reg_file_mux_out),
        .alufn(ALUSelection),
        .shamt(reg_file_mux_out[4:0]),
        .r(ALUOutput),
        .cf(carryFlag),
        .zf(zeroFlag),
        .vf(overflowFlag),
        .sf(signFlag)
    );
    
    wire [9:0] EX_MEM_flush_mux_out; 
    nBit_2x1_mux #(.N(10)) EX_MEM_flush_mux(
        .A({ID_EX_Branch, ID_EX_Jump, ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_ALUOp, ID_EX_MemWrite, ID_EX_ALUSrc, ID_EX_RegWrite}),
        .B(10'd0),
        //.sel(EX_MEM_Branch && EX_MEM_Zero),
        .sel(branchUnitOut), // might add PCMuxSel1 for this one too!!!
        .Y(EX_MEM_flush_mux_out)
    );  
    
    
    ///////////////////////////////////////////////////////////                     
    // EX/MEM
    /////////////////////////////////////////////////////////// 
    wire [31:0] EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_Inst; 
    wire EX_MEM_Branch;
    wire EX_MEM_Jump;
    wire EX_MEM_MemRead;
    wire EX_MEM_MemtoReg;
    wire [2:0] EX_MEM_ALUOp; 
    wire EX_MEM_MemWrite;
    wire EX_MEM_ALUSrc; 
    wire EX_MEM_RegWrite;
    wire [4:0] EX_MEM_Rd;
    wire EX_MEM_zero, EX_MEM_carry, EX_MEM_sign, EX_MEM_overflow;
    wire [31:0] EX_MEM_PC_adder_out;
    wire [31:0] EX_MEM_after_shift_adder_out;
    wire [1:0] EX_MEM_RegFileMuxSel;
    Nbit_reg #(246) EX_MEM (!clk, rst, 1'b1,
                            {EX_MEM_flush_mux_out, 
                            after_shift_adder_out, zeroFlag, carryFlag, signFlag, overflowFlag,
                            ALUOutput, forward_B_mux_out, ID_EX_Rd, ID_EX_Inst, ID_EX_PC, ID_EX_PC_mux_sel1, ID_EX_PC_adder_out, after_shift_adder_out, ID_EX_RegFileMuxSel},
                            {EX_MEM_Branch, EX_MEM_Jump, EX_MEM_MemRead, EX_MEM_MemtoReg, EX_MEM_ALUOp, EX_MEM_MemWrite, EX_MEM_ALUSrc, EX_MEM_RegWrite, 
                            EX_MEM_BranchAddOut, EX_MEM_zero, EX_MEM_carry, EX_MEM_sign, EX_MEM_overflow,
                            EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_Rd, EX_MEM_Inst, EX_MEM_PC, EX_MEM_PC_mux_sel1, EX_MEM_PC_adder_out, EX_MEM_after_shift_adder_out, EX_MEM_RegFileMuxSel});
                            // ADD ID_EX_INST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    
    // Branch Control Unit
    wire branchUnitOut;
    BranchControlUnit branch_control_unit(
        .funct3(EX_MEM_Inst[14:12]), 
        .cf(EX_MEM_carry),
        .zf(EX_MEM_zero),
        .vf(EX_MEM_overflow),
        .sf(EX_MEM_sign),
        .branch(EX_MEM_Branch),
        .jump(EX_MEM_Jump),
        .branchCUOut(branchUnitOut)
    );
    
    
    ///////////////////////////////////////////////////////////                     
    // MEM/WB
    /////////////////////////////////////////////////////////// 
    wire [31:0] MEM_WB_Mem_out, MEM_WB_ALU_out;
    wire MEM_WB_Branch;
    wire MEM_WB_MemRead;
    wire MEM_WB_MemtoReg;
    wire [2:0] MEM_WB_ALUOp; 
    wire MEM_WB_MemWrite;
    wire MEM_WB_ALUSrc; 
    Nbit_reg #(146) MEM_WB (clk, rst,1'b1,
                          {EX_MEM_Branch, EX_MEM_MemRead, EX_MEM_MemtoReg, EX_MEM_ALUOp, EX_MEM_MemWrite, EX_MEM_ALUSrc, EX_MEM_RegWrite, 
                          data_mem_out, EX_MEM_ALU_out, EX_MEM_Rd, EX_MEM_PC_adder_out, EX_MEM_after_shift_adder_out, EX_MEM_RegFileMuxSel},
                          {MEM_WB_Branch, MEM_WB_MemRead, MEM_WB_MemtoReg, MEM_WB_ALUOp, MEM_WB_MemWrite, MEM_WB_ALUSrc, MEM_WB_RegWrite, 
                          MEM_WB_Mem_out, MEM_WB_ALU_out, MEM_WB_Rd, MEM_WB_PC_adder_out, MEM_WB_after_shift_adder_out, MEM_WB_RegFileMuxSel} );
                          
    // MUX After Data Memory
    nBit_2x1_mux #(.N(32)) data_mem_mux(
        .A(MEM_WB_ALU_out),
        .B(MEM_WB_Mem_out),
        .sel(MEM_WB_MemtoReg),
        .Y(data_mem_mux_out)
     );
    
     
     
    /////////////////////////////////////////////////////////// 
    always@(*) begin
        if(ledSel == 2'b00) LEDs = data_mem_out[15:0];
        else if (ledSel == 2'b01) LEDs = data_mem_out[31:16];
        else begin
            LEDs = {2'b00, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, ALUSelection, zeroFlag, (Branch && zeroFlag)}; // CHECK IF THIS IS OKAY 
        end
        
        case (ssdSel)
            4'b0000: SSD = PCOutput;
            4'b0001: SSD = PC_adder_out;
            4'b0010: SSD = after_shift_adder_out;
            4'b0011: SSD = adder_mux_out;
            4'b0100: SSD = readData1;
            4'b0101: SSD = readData2;
            4'b0110: SSD = data_mem_mux_out;
            4'b0111: SSD = gen_out;
            4'b1000: SSD = left_shifted_imm; // SHOW HIM SOMETHING USEFUL
            4'b1001: SSD = reg_file_mux_out;
            4'b1010: SSD = ALUOutput;
            4'b1011: SSD = data_mem_out;
        endcase    
    end
      
        
endmodule
