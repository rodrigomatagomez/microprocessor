`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2025 02:26:58 AM
// Design Name: 
// Module Name: program_counter
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////

module program_counter #(parameter DATA_WIDTH = 32) (
    input logic clk,
    input logic arst_n,
    input logic prog_ready,
    input logic [DATA_WIDTH - 1:0] pc_in,
    output logic prog_ack,
    output logic [DATA_WIDTH - 1:0] pc_out
);
    //Secuential logic 
    always_ff @(posedge clk, negedge arst_n) begin
        if (!arst_n) begin
            pc_out <= 32'h0000_0000;
        end else if(prog_ready) begin   //UART pulse whe the instructions memory has the program ready
            pc_out <= pc_in;
        end else begin
            pc_out <= pc_out; //Don't change the instruction
        end     
    end 
	
assign prog_ack = (pc_in == pc_out) ? 1'b1 : 1'b0; //If the next instruction is exactly same as actual instruction then program is done
   
endmodule