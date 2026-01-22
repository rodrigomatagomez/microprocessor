`timescale 1ns / 1ps

import riscv_enc_pkg::*;

module microprocessor_top_tb();

parameter NUM_TESTS = 100;
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
    .instruction    (micro.instruction),
    .wb_we          (micro.wb_we),
    .wb_rd          (micro.wb_rd),
    .wb_wdata       (micro.wb_wdata)
    );

logic [4:0]rd;
logic [4:0]rs1;
logic [11:0]imm;

    initial begin
        wait (arst_n == 1'b1);
        micro.init_prf();
        repeat(NUM_TESTS) begin
        //random ADDI 
        std::randomize (rd, rs1, imm) with {
            rd inside {[1:31]};
            rs1 inside {[0:31]};
            imm inside {[0:4095]};
        };
        
        micro.drive_addi(rd, rs1, imm);
        @(posedge clk);
        end
        $finish;
    end
    
//---------------------------------------------------------------
// -------------------ASSERTIONS---------------------------------
//---------------------------------------------------------------

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



    /*initial begin
        $shm_open("shm_db");
        $shm_probe("ASMTR");
    end*/

    endmodule

