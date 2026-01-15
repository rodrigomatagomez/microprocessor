`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Rodrigo Mata 
// Create Date: 14.11.2025 18:24:51
// Design Name: 
// Module Name: control_unit
//////////////////////////////////////////////////////////////////////////////////
module control_unit(
	input logic [6:0]  opcode,             //instrucctions [6:0]
	input logic [2:0]  funct_3,            //instructions [14:12]
	input logic [6:0]  funct_7,            //instructions [31:25]
	input logic        zero,	           //input from branch(module) if rs1 and rs2 are equal
	output logic       prf_wr_en,          //write enable of prf 
	output logic [2:0] cu_imm_sel,         //control slector to immediate generator(imm_gen)
	output logic       prf_pc_mux_ctrl,    //selector to control input in ALU opoerand 1
	output logic       prf_imm_mux_ctrl,   //selector to control input in ALU opereand 2
	output logic [3:0] cu_alu_ctrl,        //selector for ALU operation
	output logic [1:0] cu_mem_out_mux_sel, //selector for mux data_out,alu_result,next_instruction directions to prf data in
	output logic       cu_data_mem_wr_en,  //write enable for data mem
	output logic       cu_pc_add_sel,      //selector to add +4 or +2 to the next instrucion (+2 is for future architecture implementation) 
	output logic       branch_taken        //flag in order to evaluate only in  BEQ and JAL instructions 
);
//Define the instructions 
`include "defines.svh"
	always_comb begin 
	 prf_wr_en =             1'b1;          //enable prf write
     cu_data_mem_wr_en =     1'b0;          //disable data_mem write
     cu_imm_sel =            IMM_I;         //use IMM_I_TYPE decodification
     prf_pc_mux_ctrl =       1'b0;          //use rs1 as opreand 1 in ALU
     prf_imm_mux_ctrl =      1'b1;          //don't use rs2 instead use imm_gen as operand 2 in ALU
     cu_pc_add_sel =         1'b0;          //Add +4 to pc_in
     cu_mem_out_mux_sel =    ALU_TO_PRF;    //send the result of ALU to prf data_in
     cu_alu_ctrl =           ALU_ADD;       //ADD operation in ALU  
     branch_taken =          1'b0;          //Never take a branch in I_TYPE so that mux_pc_in is PC+4  
        case (opcode)
            OPCODE_I_TYPE: begin    //Type I instructions
                 case (funct_3) 
                     //(addi)
                    ADDI: begin 
                        cu_alu_ctrl =           ALU_ADD;       //ADD operation in ALU
                    end 
                    //(slti)
                    SLTI: begin 
                        cu_alu_ctrl =           ALU_SLT;       //SLT operation in ALU       
                    end
                    //(sltiu)
                    SLTIU: begin 
                        cu_alu_ctrl =           ALU_SLTU;      //SLTU operation in ALU   
                    end
                    //(xori)
                    XORI: begin 
                        cu_alu_ctrl =           ALU_XOR;       //XOR operation in ALU
                    end
                    //(slti)
                    ORI: begin 
                        cu_alu_ctrl =           ALU_OR;        //OR operation in ALU      
                    end
                    //(ANDI)
                    ANDI: begin 
                        cu_alu_ctrl =           ALU_AND;       //AND operation in ALU
                    end
                    default: begin                   
                        cu_alu_ctrl =           ALU_ADD;       //ADD operation in ALU
                    end
                 endcase
            end	
            OPCODE_B_TYPE: begin    //Type B instructions 
                prf_wr_en =             1'b0;          //disable prf write
                cu_imm_sel =            IMM_B;         //use IMM_B_TYPE 
                prf_pc_mux_ctrl =       1'b1;          //use rs1 as opreand 1 in ALU
                    //Type B(BEQ)
                    case (funct_3)
                        BEQ: begin
                            if (zero == 1'b1) begin //This flag is going to be '1' if rs1 = rs2
                                cu_alu_ctrl =           ALU_ADD;       //ADD operation in ALU
                                branch_taken = 1'b1;                   //Select the direction of the branch (branch taken)
                            end else 
                                branch_taken = 1'b0;                  
                        end
                        //TODO: Add more types of branches in order to roun any program 
                        default: begin 
                            cu_alu_ctrl =           ALU_ADD;       //ADD operation in ALU
                            branch_taken =          1'b0;          //branch not taken
                        end                    
                    endcase
            end
            OPCODE_R_TYPE: begin
                 cu_imm_sel =            IMM_NF;         //use IMM_NO_FUNCTION_TYPE 
                 prf_imm_mux_ctrl =      1'b0;          //use rs2 as operand 2 in ALU
                 if (funct_7 == 7'b0000000) begin       //The instructions bellow have this code  funct_7
                     case (funct_3)     //The changes of this types of R operations comes from funct_3
                         //ADDITION OPERATION
                         ADD: begin 
                             cu_alu_ctrl =           ALU_ADD;       //ADD operation in ALU
                         end
                         //LOGICAL LEFT SHIFT
                         SLL: begin 
                             cu_alu_ctrl =           ALU_SLL;       //SLL operation in ALU
                         end
                         //SIGNED COMPARISON
                         SLT: begin 
                             cu_alu_ctrl =           ALU_SLT;       //SLT operation in ALU
                         end
                         //UNSIGNED COMPARISON
                         SLTU: begin 
                             cu_alu_ctrl =           ALU_SLTU;       //SLTU operation in ALU
                         end
                         //XOR
                         XOR_: begin 
                             cu_alu_ctrl =           ALU_XOR;       //XOR operation in ALU
                         end
                         //RIGHT LOGICAL SHIFT 
                         SRL: begin 
                             cu_alu_ctrl =           ALU_SRL;       //SRL operation in ALU
                         end
                         //OR
                         OR_: begin 
                             cu_alu_ctrl =           ALU_OR;        //OR operation in ALU
                         end
                         //AND
                         AND_: begin 
                             cu_alu_ctrl =           ALU_AND;       //AND operation in ALU
                         end
                         default: begin 
                             cu_alu_ctrl =           ALU_ADD;       //ADD operation in ALU
                         end
                     endcase
                 end else if (funct_7 == 7'b0100000) begin   //The instructions bellow have this code  funct_7
                     case(funct_3) 
                         //SUBTRACTION OPERATION
                         SUB: begin
                             cu_alu_ctrl =           ALU_SUB;       //SUB operation in ALU
                         end
                         //SIGN-EXTEND SHIFT OPERATION
                         SRA: begin 
                             cu_alu_ctrl =           ALU_SRA;       //Arithmetic right shift operation in ALU
                         end
                         default: begin
                             cu_alu_ctrl =           ALU_ADD;       //ADD operation in ALU
                         end
                     endcase 
                 end else begin 
                     cu_alu_ctrl =           ALU_ADD;               //ADD operation in ALU   
                 end
            end
            OPCODE_J_TYPE: begin    //In this RISCV architecture it only exists jump and link (JAL) operation
                 cu_imm_sel =            IMM_J;                 //use IMM_NO_FUNCTION_TYPE 
                 prf_pc_mux_ctrl =       1'b1;                  //use pc_out as opreand 1 in ALU
                 cu_mem_out_mux_sel =    INSTRUCTION_TO_PRF;    //send the result of ALU to prf data_in       
                 cu_alu_ctrl =           ALU_ADD;               //ALU operation in ALU
                 branch_taken =          1'b1;                  //always take the branch
            end	
            //TODO: Add more types of J instructions
            default: begin 
                 prf_wr_en =             1'b0;          //enable prf write
                 cu_alu_ctrl =           ALU_ADD;       //ADD operation in ALU   
            end
        endcase  
	end
endmodule