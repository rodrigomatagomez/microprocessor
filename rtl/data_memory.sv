module data_memory #(
    parameter DEPTH = 1024
)(
    input  logic        clk,
    input  logic        wr_en,
    input  logic [31:0] addr,      // byte address (ALU result)
    input  logic [31:0] data_in,   // store data (rs2)
    output logic [31:0] data_out   // raw 32-bit word read
);

    logic [31:0] mem [0:DEPTH-1];

    // Word index: byte address -> word address (drop 2 LSBs)
    logic [$clog2(DEPTH)-1:0] word_idx;
    assign word_idx = addr[11:2];  // for DEPTH=1024 (4KB), safe indexing

    // Combinational read 
    assign data_out = mem[word_idx];

    // Synchronous write
    always_ff @(posedge clk) begin
        if (wr_en) begin
            mem[word_idx] <= data_in;
        end
    end

endmodule
