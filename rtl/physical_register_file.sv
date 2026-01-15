`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cinvestav
// Engineer: Armando sebastian Ramirez Jimenez
// 
// Create Date: 18.11.2025 15:36:43
// Design Name: 
// Module Name: bank_reg_s
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

module physical_register_file #(parameter DIR_WIDTH = 10, parameter DATA_WIDTH = 256)(
    input logic clk,                    //Clock signal
    input logic arst_n,                 //Reset signal
    input logic write_en,               //Write enable signal
    input logic [DIR_WIDTH - 1:0] read_dir1,        //Read direction 1
    input logic [DIR_WIDTH - 1:0] read_dir2,        //Read direction 2
    input logic [DIR_WIDTH - 1:0] write_dir,        //Write direction
    input logic [DATA_WIDTH - 1:0] write_data,      //Data to write
    output logic [DATA_WIDTH - 1:0] read_data1,     //Readed Data 1
    output logic [DATA_WIDTH - 1:0] read_data2,      //Readed Data 2
    output logic [DATA_WIDTH -1:0] fibb_out
    );
    
   // `include "../../defines.svh"
    
    logic [DATA_WIDTH - 1:0] prf [1:(2**DIR_WIDTH) - 1];    //Physical Register File 32*32bits
    
    always_ff@(posedge clk,negedge arst_n)begin 
    //registers <= '{default:'0};
        if (arst_n == 1'b0)begin                        //Condition of reset
            for (int i = 1 ; i < DATA_WIDTH; i++) begin         //For cicle to reset to 0 all values of memory array
                prf [i]<= '0;
            end
        end else begin
            if (write_en)begin    //If write enable is set and the direction of write is not 0, then write memory array
                prf [write_dir] <= write_data;              //Memory array assignation
            end
        end
    end
    always_comb begin
        read_data1 = read_dir1 == '0 ? '0 : prf [read_dir1];      //Assignation of readed data 1 depending of read direction 1
        read_data2 = read_dir2 == '0 ? '0 : prf [read_dir2];      //Assignation of readed data 2 depending of read direction 2
    end
    assign fibb_out = prf[5];

endmodule