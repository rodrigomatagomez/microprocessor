`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2025 01:27:37 AM
// Design Name: 
// Module Name: imm_gen_tb
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


module imm_gen_tb();
    //Signals
    logic [31:0] instr;
    logic [2:0] imm_sel;
    logic [31:0] imm_out;
        //local params
`include "../../defines.svh"
    
    initial begin
        imm_sel = IMM_I;
        instr = 32'b00000000101000000000011000010011; //x0 + 10
        #10ns;
        imm_sel = IMM_B;
        instr = 32'b00000000000001100000110001100011; //brwanch 24 so immm  = 24
        #10ns;
        imm_sel = IMM_J;
        instr = 32'b11111110110111111111000001101111; //jal 20 so immm  = -20
        #10ns; 
        $finish;    
    end
    
    imm_gen imm_gen_i (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm_out(imm_out)
    );
        
	// XCELIUM WFS
 	initial begin
		$shm_open("shm_db");
		$shm_probe("ASMTR");
  end
  
endmodule

