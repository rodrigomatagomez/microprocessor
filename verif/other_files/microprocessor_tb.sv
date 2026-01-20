module microprocessor_tb ();

// `include "defines.svh"
    
    bit clk;
    bit arst_n;
    
    // para el testbench (randomizados)
    logic [DIR_WIDTH-1:0] rd, rs1, rs2;
    logic [12:0] imm_bq;
    logic [20:0] imm_jal;
    
    logic [DATA_WIDTH-1:0] instruction_tb, instruction_tb_addi, instruction_tb_add, instruction_tb_beq, instruction_tb_jal;
    logic [DIR_WIDTH-1:0] rd_tb, rs1_tb, rs2_tb;
    logic [11:0] imm_tb;  

    // para el BIND 
    logic [DATA_WIDTH-1:0] alu_result;
    logic [DATA_WIDTH-1:0] pc_out, pc_imm; // Se ales para conectar al bind
    logic memread, memwrite, memtoreg;
    
    //CHECKS
    logic [31:0] pc_before;
    logic [31:0] imm_check;
    logic [31:0] rd_expected;
    logic [31:0] beq_taken;
    logic [31:0] beq_notaken;
    logic equal;
    logic [6:0] count_add, count_addi, count_beq, count_jal, count_add_g, count_addi_g, count_beq_g, count_jal_g;
    
    always #5ns clk = !clk;
	assign #10ns arst_n = 1'b1;

    microprocessor_if tbprocessor_if(clk, arst_n);
    //microprocessor_top tbprocessor_top(clk, arst_n);    
    
    microprocessor_top microprocessor_i ( 
        .clk(clk),
        .arst_n(arst_n),
				.prog_ready(1'b1),
				.w_en(1'b0),
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
    `define  BRANCH_PATH microprocessor_i.branch_i
    
    typedef enum bit [6:0] {
      addi = 7'b0010011,
      add  = 7'b0110011,
      beq  = 7'b1100011,
      jal  = 7'b1101111
    } operation;
    
    operation current_instruction;      
  
    initial begin
    count_add = 0; count_addi= 0; count_beq = 0; count_jal = 0;
    count_add_g = 0; count_addi_g = 0; count_beq_g = 0; count_jal_g = 0;
    
    wait (arst_n);
      $display("--- Decodificador de Instrucciones (RISC-V Opcode) ---");

      repeat (100) @(posedge clk) begin
			randcase
        1 :  begin // ADDI
		instruction_tb_addi = '0; instruction_tb_add= '0; instruction_tb_beq= '0; instruction_tb_jal= '0;
                std::randomize(rd,rs1);
                tbprocessor_if.write_addi_instr(rd,rs1);
                current_instruction = tbprocessor_if.instruction[6:0];
                rd_tb = tbprocessor_if.instruction[11:7];
                rs1_tb = tbprocessor_if.instruction[19:15];
                imm_tb = tbprocessor_if.instruction[DATA_WIDTH-1:DATA_WIDTH-12];
                instruction_tb_addi = tbprocessor_if.instruction;
                count_addi = count_addi + 1;
                @(posedge clk); // Esperamos un ciclo
                    //if (`ALU_PATH.alu_result !== (`ALU_PATH.operand1 + `ALU_PATH.operand2)) begin
                    //  $error("ERROR EN ADDI!! ALU: esperado %0d + %0d = %0d, obtenido = %0d",
                    //         `ALU_PATH.operand1, `ALU_PATH.operand2,
                    //         `ALU_PATH.operand1 + `ALU_PATH.operand2, `ALU_PATH.alu_result);
                    //end
                    //if (`BANK_REG_PATH.write_dir !== rd) begin
                    //  $error("ERROR EN ADDI!! Direcci n esperada = %0d, direcci n escrita = %0d",
                    //         rd, `BANK_REG_PATH.write_dir);
                    //end else begin 
                    //count_addi_g = count_addi_g + 1;
                    //end
              end

        1 : begin // ADD
		instruction_tb_addi = '0; instruction_tb_add= '0; instruction_tb_beq= '0; instruction_tb_jal= '0;
                std::randomize(rs1,rs2,rd);
                tbprocessor_if.write_add_instr(rs1,rs2,rd);
                current_instruction = tbprocessor_if.instruction[6:0];
                rd_tb = tbprocessor_if.instruction[11:7];
                rs1_tb = tbprocessor_if.instruction[19:15];
                rs2_tb = tbprocessor_if.instruction[24:20];
                instruction_tb_add = tbprocessor_if.instruction;
                count_add =count_add +1;
                @(posedge clk); 
                //if (`ALU_PATH.alu_result !== (`ALU_PATH.operand1 + `ALU_PATH.operand2)) begin
                //  $error("ERROR EN ADD!! ALU: esperado %0d + %0d = %0d, obtenido %0d",
                //         `ALU_PATH.operand1, `ALU_PATH.operand2,
                //         `ALU_PATH.operand1 + `ALU_PATH.operand2, `ALU_PATH.alu_result);
                //end        
                //if (`BANK_REG_PATH.write_dir !== rd) begin
                //  $error("ERROR EN ADD!! Direcci n esperada = %0d, direcci n escrita = %0d",
                //         rd, `BANK_REG_PATH.write_dir);
                //end else begin 
                //count_add_g = count_add_g + 1;
                //end
              end


        1 : begin //BEQ
		instruction_tb_addi = '0; instruction_tb_add= '0; instruction_tb_beq= '0; instruction_tb_jal= '0;
                std::randomize(rs1,rs2,imm_bq);
                tbprocessor_if.write_beq_instr(rs1,rs2,imm_bq);
                current_instruction = tbprocessor_if.instruction[6:0];
                rs1_tb = tbprocessor_if.instruction[19:15];
                rs2_tb = tbprocessor_if.instruction[24:20];
                instruction_tb_beq = tbprocessor_if.instruction;
                pc_before = $signed(`PC_PATH.pc_out);
                equal = (rs1 == rs2);
                imm_check = $signed({imm_bq[12], imm_bq[10:5], imm_bq[4:1], imm_bq[11], 1'b0});
                beq_taken = $signed(pc_before) + imm_check;
                beq_notaken = $signed(pc_before) + 4;
                rd_expected = equal ? $signed(beq_taken) : $signed(beq_notaken);
                count_beq = count_beq + 1;
                @(posedge clk);
                //if ($signed(`PC_PATH.pc_out) !== $signed(rd_expected)) begin
                //  $error("ERROR BEQ FALL !\n  PC actual     = %d \n   PC anterior    = %d \n %d, %d -> condici n: %0s\n   Inmediato B    = %0d (%b)\n  Esperado       = %d  (%0s)",
                //         $signed(`PC_PATH.pc_out), $signed(pc_before),
                //         rs1, rs2, equal ? "IGUALES -> TOMADO" : "DIFERENTES -> NO TOMADO",
                //         $signed(imm_check), $signed(imm_bq),
                //         $signed(rd_expected),
                //         equal ? "SALTO TOMADO" : "SALTO NO TOMADO");
                //end else begin
                //    count_beq_g = count_beq_g + 1;
                //end 
		    end
        
        5 : begin //JAL
		instruction_tb_addi = '0; instruction_tb_add= '0; instruction_tb_beq= '0; instruction_tb_jal= '0;
                std::randomize(rd,imm_jal);
                tbprocessor_if.write_jal_instr (rd,imm_jal);
                current_instruction = tbprocessor_if.instruction[6:0];
                rd_tb = tbprocessor_if.instruction[11:7];
                instruction_tb_jal = tbprocessor_if.instruction;
                pc_before = $signed(`PC_PATH.pc_out);
                imm_check = $signed({{12{imm_jal[20]}}, imm_jal[20:0], 1'b0});
                rd_expected = $signed(pc_before) + $signed(imm_check);
                count_jal = count_jal + 1;
                @(posedge clk);
                //if ($signed(`PC_PATH.pc_out) !== $signed(rd_expected)) begin
                //  $error("ERROR JAL: Salto incorrecto!\n   PC actual = %d\n   Esperado    = PC(%d) + imm(%0d) = %d",
                //         $signed(`PC_PATH.pc_out), $signed(pc_before), $signed(imm_check), $signed(rd_expected));
                //end 
                //if ($signed(`BANK_REG_PATH.write_dir) !== $signed(rd_expected)) begin
                //  $error("ERROR JAL: write_dir = %0d, esperado rd=%0d", $signed(`BANK_REG_PATH.write_dir), $signed(rd_expected));
                //end
                //if ($signed(`BANK_REG_PATH.write_data) !== $signed(pc_before) + 4) begin
                //  $error("ERROR JAL: No guard  PC+4 en rd!\n   Escrito = %d\n   Esperado = PC+4 = %d",
                //         $signed(`BANK_REG_PATH.write_data), $signed(pc_before) + 4);
                //end else begin
                //    count_jal_g = count_jal_g + 1;
		          	//end
		    end
      endcase  
    end  
    $display("TOTAL DE OPERACIONES = %d \n ADD  = %d    Sin errores = %d \n ADDI = %d    Sin errores = %d \n BEQ  = %d    Sin errores = %d \n JAL  = %d    Sin errores = %d ",count_add+count_addi+count_beq+count_jal,count_add,count_add_g, count_addi,count_addi_g, count_beq,count_beq_g, count_jal, count_jal_g);   
end

        
    initial begin // Initial block to open shared memory and probe signals
			$shm_open("shm_db");
			$shm_probe("ASMTR");
	end
    
	initial begin // Timeout thread
		#1ms;
		$finish;
	end


       

		logic probe_signal_beq;
		logic [31:0] probe1, probe2;
		assign probe1 = microprocessor_i.prf_i.prf[rs1];
		assign probe2 = microprocessor_i.prf_i.prf[rs2];
		assign probe_signal_beq = microprocessor_i.prf_i.prf[rs1] == microprocessor_i.prf_i.prf[rs2];

    
    //ADDI 
    // Comprueba que si rd = 0, se escribe 0. Si rd != 0, se escribe rs1_val_expected + Inmediato.
    `AST(uC, instruction_tb_addi, 
        current_instruction == OPCODE_I_TYPE[6:0] |=>,
        $past(rd_tb) == 5'd0 ? 
            // Caso: rd es X0 (debe escribir 0)
            $signed(`BANK_REG_PATH.prf[$past(rd_tb)]) == 32'd0 : 
            // Caso: rd es un registro válido (debe escribir la suma)
            $signed(`BANK_REG_PATH.prf[$past(rd_tb)]) == (
                // rs1_val: Si rs1 == 0, se usa 0; si no, se usa el valor leído
                ($past(rs1_tb) == 5'd0 ? 32'd0 : $past($signed(`BANK_REG_PATH.read_data1))) 
                + $past($signed(`IMM_GEN_PATH.imm_out))
            )
    )
    
    // ADD 
    // Comprueba que si rd = 0, se escribe 0. Si rd != 0, se escribe rs1_val_expected + rs2_val_expected.
    `AST(uC, instruction_tb_add, 
       current_instruction  == OPCODE_R_TYPE[6:0] |=>,
        $past(rd_tb) == 5'd0 ? 
            // Caso: rd es X0 (debe escribir 0)
            $signed(`BANK_REG_PATH.prf[$past(rd_tb)]) == 32'd0 : 
            // Caso: rd es un registro válido (debe escribir la suma de los operandos corregidos)
            $signed(`BANK_REG_PATH.prf[$past(rd_tb)]) == (
                // rs1_val: Si rs1 == 0, se usa 0; si no, se usa read_data1
                ($past(rs1_tb) == 5'd0 ? 32'd0 : $past($signed(`BANK_REG_PATH.read_data1))) 
                +
                // rs2_val: Si rs2 == 0, se usa 0; si no, se usa read_data2
                ($past(rs2_tb) == 5'd0 ? 32'd0 : $past($signed(`BANK_REG_PATH.read_data2)))
            )
    )
     
//BEQ
  `AST(uC, instruction_tb_beq,
    current_instruction == OPCODE_B_TYPE[6:0] |=>,  
		$past(`BRANCH_PATH.rs_1) == $past(`BRANCH_PATH.rs_2) ? 
		 $signed(microprocessor_i.pc_i.pc_in) == $past(microprocessor_i.pc_i.pc_out) + $past(`IMM_GEN_PATH.imm_out) : // branch taken
		 $signed(microprocessor_i.pc_i.pc_in) == $past(microprocessor_i.pc_i.pc_out) + 32'd4 // branch not taken
)
      // JAL
    // Salto del PC 
    `AST(uC, instruction_tb_jal,
      current_instruction[6:0]  == OPCODE_J_TYPE[6:0] |=>,  
        microprocessor_i.pc_i.pc_in == $past(microprocessor_i.pc_i.pc_out + microprocessor_i.imm_gen_i.imm_out)
    )
  
endmodule
