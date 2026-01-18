`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 10:44:41 PM
// Design Name: 
// Module Name: imm_gen
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////


module imm_gen(
    input logic [31:0] instr,      // Instructions from program memory
    input logic [2:0] imm_sel,     // 000 = I-type, 001 = S-type ,010 = B-type, 011 = U-type, 100 = J-type of control unit 
    output logic [31:0] imm_out    // output for ALU and PC
    );
    
`include "defines.svh"             //define the imm instructions 

always_comb begin 
    unique case (imm_sel)
        /*   I-type (ADDI)  original immediate 12 bits   instr[31:20]
                        12 bits     5bits   3bits    5bits  7bits 
                        31:20       19:15   14:12    11:7   6:0
                        imm[31:20]  rs1     funct3   rd     opcode
        */
        IMM_I: begin //000 = I-type
            imm_out = {{20{instr[31]}}, instr[31:20]}; //signed extension (repeat 20 times the MSB)
        end


        /*   S-type     original immediate 12 bits   imm[11:5]  imm[4:0]
                        7  bits   5bits   5bits    3bits    5bits     7bits 
                        31:25     24:20   19:15    14:12    11:7      6:0 
                        imm[11:5] rs2     rs1      funct3   imm[4:0]  opcode
        */        
		IMM_S: begin //001 = S-type
            imm_out = { {20{instr[31]}},instr[31:25], instr[11:7] };//signed extension (repeat 20 times the MSB)
        end
        
        /*   B-type     original immediate 12 bits + 1'b0   mm[12|10:5|4:1|11]
                      1 bit   6bits     5bits   5bits    3bits    4bits     1bit     7bits 
                      31      30:25     24:20   19:15    14:12    11:8      7        6:0 
                      imm[12] imm[10:5] rs2     rs1      funct3   imm[4:1]  imm[11]  opcode
        */  
        IMM_B: begin  //010 = B-type
             imm_out = { {20{instr[31]}}, {instr[7], instr[30:25], instr[11:8], 1'b0 } };
        end
        
         /*   U-type     original immediate 20 bits   instr[31:12]
                          20 bits       5bit     7bits 
                          31:12         11:7     6:0 
                          imm[31:12]    rd       opcode
        */         
        IMM_U: begin  // 011 = U-type
            imm_out = {  instr[31:12], {12{1'b0}} };
        end
        
        /*   J-type     original immediate 20 bits +1'b0  imm[20|10:1|11|19:12]
                        1bit    10bits     1bit     8bits      5bits     7bits 
                        31      30:21      20       19:12      11:7      6:0 
                        imm[20] imm[10:1]  imm[11]  imm[19:12] rd        opcode
        */   
        IMM_J: begin // 100 = J-type
            imm_out = { {12{instr[31]}}, {instr[19:12], instr[20], instr[30:21], 1'b0 } };
        end
        default: imm_out = '0;
    endcase
end

endmodule



