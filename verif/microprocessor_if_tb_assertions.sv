module microprocessor_if_tb_assertions(
//Blackbox signals
    input logic clk, 
    input logic arst_n,
    input logic [6:0] current_instruction,
    input logic memread , 
    input logic memwrite, 
    input logic memtoreg, 
    input logic [DATA_WIDTH-1:0] alu_result,
    input logic [DIR_WIDTH-1:0] rd, rs1, rs2,
    input logic [DATA_WIDTH-1:0] instruction_tb_addi, instruction_tb_add, instruction_tb_beq, instruction_tb_jal,
    
    //Whitebox signals
    //Registers bank
    input logic [DATA_WIDTH-1:0] prf [1:DATA_WIDTH-1],
    input logic [DATA_WIDTH-1:0] pc_out,
    input logic [DATA_WIDTH-1:0] pc_imm
    );
    
  `include "includes.svh"

    microprocessor_if tbprocessor_if(clk, arst_n);
    microprocessor_top tbprocessor_top(clk, arst_n);    
    microprocessor_if_tb tbprocessor_if_tb(clk, arst_n);
    
    microprocessor_top microprocessor_i ( 
        .clk(clk),
        .arst_n(arst_n),
        .instruction(tbprocessor_if.instruction)
    );
    
    
    `define  MEM_PATH microprocessor_i.instruction_memory_i
	`define  ALU_PATH microprocessor_i.alu_i
	`define  BANK_REG_PATH microprocessor_i.prf_i
	`define  PC_PATH microprocessor_i.pc_i
	`define  IMM_GEN_PATH microprocessor_i.imm_gen_i
	`define  MUX_IMM_PATH microprocessor_i.mux_imm_gen_i
	`define  MUX_PC_PATH microprocessor_i.mux_pc_i
	`define  CU_PATH microprocessor_i.control_unit_i
	

      `AST(uC, instruction_tb_addi, current_instruction == OPCODE_I_TYPE[6:0] |=>,
                 $signed(`BANK_REG_PATH.prf[$past(rd)]) == $past($signed(`BANK_REG_PATH.read_data1)) + $past($signed(`IMM_GEN_PATH.imm_out)))

	`AST(uC, instruction_tb_add, 
        current_instruction == OPCODE_R_TYPE[6:0] |-> ,
        alu_i.alu_result == (prf_i.read_data1) + (prf_i.read_data2))


    `AST(uC, instruction_tb_beq,
        current_instruction == OPCODE_B_TYPE[6:0] |=>, 
        $past(prf[rs1] == prf[rs2]) ? 
         pc_i.pc == $past(pc_i.pc) + $past(imm_gen_i.imm_out) : // branch taken
         pc_i.pc == $past(pc_i.pc) + 32'd4 // branch not taken
     )
    
    `AST(uC, instruction_tb_jal,
        current_instruction == OPCODE_J_TYPE[6:0] |=>, 
        pc_i.pc == $past(pc_i.pc + imm_gen_i.imm_out) // unconditional jump
    )

    endmodule
   
    bind microprocessor_top microprocessor_tb microprocessor_if_tb (
        // blackbox (Conexiones al DUT principal)
        .clk        (clk),
        .arst_n     (arst_n), 
        .memread    (memread),
        .memwrite   (memwrite),
        .memtoreg   (memtoreg),
        .alu_result (alu_result),
        //
        .current_instruction (current_instruction),
        .instruction_tb_addi (instruction_tb_addi),
        .instruction_tb_add (instruction_tb_add),
        .instruction_tb_beq (instruction_tb_beq),
        .instruction_tb_jal (instruction_tb_jal),
        // whitebox (Conexiones a sub-instancias)
        .prf        (microprocessor_i.prf_i.prf), // register bank
        .pc_out     (pc_out),
        .pc_imm     (pc_imm)
    );