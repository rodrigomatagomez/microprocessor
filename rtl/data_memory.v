`timescale 1ns / 1ps

module data_memory #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 1024
)(
    input  wire                  clk,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] addr,      // byte address
    input  wire [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out
);

    // -------------------------------------------------------------------------
    // clog2 function (replacement for $clog2 in Verilog)
    // -------------------------------------------------------------------------
    function integer clog2;
        input integer value;
        integer i;
        begin
            value = value - 1;
            for (i = 0; value > 0; i = i + 1)
                value = value >> 1;
            clog2 = i;
        end
    endfunction

    localparam ADDR_WIDTH = clog2(DEPTH);

    // -------------------------------------------------------------------------
    // Memory declaration
    // -------------------------------------------------------------------------
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    wire [ADDR_WIDTH-1:0] word_addr;

    // byte → word address conversion
    assign word_addr = addr[ADDR_WIDTH+1:2];

    // -------------------------------------------------------------------------
    // Write
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (wr_en) begin
            mem[word_addr] <= data_in;
        end
    end

    // -------------------------------------------------------------------------
    // Read
    // -------------------------------------------------------------------------
    assign data_out = mem[word_addr];

endmodule