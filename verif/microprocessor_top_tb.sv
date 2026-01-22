`timescale 1ns / 1ps

//import riscv_enc_pkg::*;

module microprocessor_top_tb();

parameter NUM_TESTS = 1000;
bit clk;
bit arst_n;

//interface
microprocessor_if micro(.clk(clk), .arst_n(arst_n));

always #5 clk = !clk;

initial begin
    arst_n = 1'b0;
    #20;
    arst_n = 1'b1;
end

//top
microprocessor_top microprocessor_DUT (
    .clk            (clk),
    .arst_n         (arst_n),
    .instruction    (micro.instruction)
    );

logic [4:0]rd;
logic [4:0]rs1;
logic [11:0]imm;

initial begin
	wait (arst_n == 1'b1);
        micro.init_prf();
        @(posedge clk);
        repeat(NUM_TESTS) begin
        //random ADDI 
        micro.build_addi_random(rd, rs1, imm);
        @(posedge clk);
        end
        $finish;
end
//---------------------------------------------------------------
//--------Check if the instrucction is adi-----------------------
//---------------------------------------------------------------
property check_addi_instr;
    @(posedge clk) disable iff (!arst_n)
        micro.check_addi(micro.instruction);
endproperty

assert property (check_addi_instr)
    else $error("Instruction is not ADDI: instr=%h", micro.instruction);
//---------------------------------------------------------------
property check_addi_result;
    @(posedge clk) disable iff (!arst_n)
        //check if instruction is ADDI
        (microprocessor_DUT.instruction  [6:0]   ==  7'b0010011  && microprocessor_DUT.instruction  [14:12] ==  3'b000) |-> //then result
        (microprocessor_DUT.prf_i.write_data == microprocessor_DUT.alu_i.alu_result);
endproperty

assert property (check_addi_result)
    else $error("ADD failed");
    /*initial begin
        $shm_open("shm_db");
        $shm_probe("ASMTR");
    end*/

    endmodule

