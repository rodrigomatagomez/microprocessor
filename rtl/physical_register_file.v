`timescale 1ns / 1ps
//------------------------------------------------------------------------------
// Module: physical_register_file
// Description:
//   2-read / 1-write register file for an RV32-style datapath.
//------------------------------------------------------------------------------

module physical_register_file #(
    parameter DIR_WIDTH  = 5,   // 5 bits -> 32 registers
    parameter DATA_WIDTH = 32
)(
    input  wire                     clk,
    input  wire                     arst_n,
    input  wire                     write_en,
    input  wire [DIR_WIDTH-1:0]     read_dir1,
    input  wire [DIR_WIDTH-1:0]     read_dir2,
    input  wire [DIR_WIDTH-1:0]     write_dir,
    input  wire [DATA_WIDTH-1:0]    write_data,
    output wire [DATA_WIDTH-1:0]    read_data1,
    output wire [DATA_WIDTH-1:0]    read_data2
);

    // Register storage
    reg [DATA_WIDTH-1:0] prf [0:(2**DIR_WIDTH)-1];

    //--------------------------------------------------------------------------
    // Synchronous write port
    //--------------------------------------------------------------------------
    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            prf[0] <= {DATA_WIDTH{1'b0}}; // x0 = 0
        end
        else if (write_en && (write_dir != {DIR_WIDTH{1'b0}})) begin
            prf[write_dir] <= write_data;
        end
    end

    //--------------------------------------------------------------------------
    // Combinational read ports
    //--------------------------------------------------------------------------
    assign read_data1 = (read_dir1 == {DIR_WIDTH{1'b0}})
                        ? {DATA_WIDTH{1'b0}}
                        : prf[read_dir1];

    assign read_data2 = (read_dir2 == {DIR_WIDTH{1'b0}})
                        ? {DATA_WIDTH{1'b0}}
                        : prf[read_dir2];

endmodule