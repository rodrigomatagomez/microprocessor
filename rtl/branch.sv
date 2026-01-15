`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 10:15:02 AM
// Design Name: 
// Module Name: branch
//////////////////////////////////////////////////////////////////////////////////


module branch #(parameter DATA_WIDTH = 32)(
    input logic [DATA_WIDTH - 1: 0]rs_1,
    input logic [DATA_WIDTH - 1: 0]rs_2,
    output logic branch_taken
    );
    
    assign branch_taken = (rs_1 == rs_2) ? 1'b1 : 1'b0;  //Zero flag
    
endmodule
