interface microprocessor_if (input logic clk, input logic arst_n);

	localparam ADD_PROB = 1;
	localparam ADDI_PROB = 1;
	localparam BEQ_PROB = 1;
	localparam JAL_PROB = 1;

	logic [DATA_WIDTH-1:0] instruction;


	function  write_addi_instr(logic [DIR_WIDTH-1:0] rd, logic [DIR_WIDTH-1:0] rs1); // Random immediate
		logic [11:0] imm;
		logic [DATA_WIDTH-1:0] addi;	

		std::randomize(imm);
		//imm = 12'd500;

		addi = {imm, rs1, IMM_I, rd, OPCODE_I_TYPE};
		instruction = addi;
	endfunction

	function  write_add_instr(logic [DIR_WIDTH-1:0] rs1, logic [DIR_WIDTH-1:0] rs2, logic [DIR_WIDTH-1:0] rd);
		logic [DATA_WIDTH-1:0] add;	

		add = {ALU_ADD, rs2, rs1, IMM_I, rd, OPCODE_R_TYPE};
		instruction = add;
	endfunction

	function  write_beq_instr(logic [DIR_WIDTH-1:0] rs1, logic [DIR_WIDTH-1:0] rs2, logic [12:0] imm);
		logic [DATA_WIDTH-1:0] beq;

		beq = {imm[12], imm[10:5], rs2, rs1, IMM_I, imm[4:1], imm[11], OPCODE_B_TYPE};
		instruction = beq;
	endfunction

	function  write_jal_instr (logic [DIR_WIDTH-1:0] rd, logic [20:0] imm);
		logic [DATA_WIDTH-1:0] jal;

		jal = {imm[20], imm[10:1], imm[11], imm[19:12], rd, OPCODE_J_TYPE};
		instruction = jal;
	endfunction

	function wr_random_instr(logic [DIR_WIDTH-1:0] rd, logic [DIR_WIDTH-1:0] rs1, logic [DIR_WIDTH-1:0] rs2, logic [20:0] imm);
		randcase
			ADDI_PROB: begin
				write_addi_instr(rd, rs1);
			end
			ADD_PROB: begin
				write_add_instr(rs1, rs2, rd);
			end
			BEQ_PROB: begin
				write_beq_instr(rs1, rs2, imm[12:0]);
			end
			JAL_PROB: begin
				write_jal_instr(rd, imm[20:0]);
			end		
		endcase
	endfunction

endinterface
