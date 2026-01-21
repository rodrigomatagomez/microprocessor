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
    .clk         (clk),
    .arst_n      (arst_n),
    .instruction (micro.instruction)
    );

logic [4:0]rd;
logic [4:0]rs1;
logic [11:0]imm;

    initial begin
        wait (arst_n == 1'b1);
        micro.init_prf();
        /*repeat(NUM_TESTS) begin
        //random ADDI 
        std::randomize (rd, imm) with {
            rd inside {[1:31]};
            imm inside {[0:4095]};
        };
        
        micro.drive_addi(rd, 5'd0, imm);
        @(posedge clk);
        end*/
        $finish;
    end

    /*initial begin
        $shm_open("shm_db");
        $shm_probe("ASMTR");
    end*/

    endmodule

