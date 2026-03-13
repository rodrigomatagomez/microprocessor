module instruction_memory #(
    parameter MEM_SIZE = 4096
)(
    input  logic        clk,

    // fetch
    input  logic [DATA_WIDTH-1:0] pc,
    output logic [31:0] instr,

    // write port (loader / wishbone)
    input  logic        we,
    input  logic [DATA_WIDTH-1:0] wr_addr,
    input  logic [DATA_WIDTH-1:0] wr_data
);

logic [7:0] mem [0:MEM_SIZE-1];


// -----------------------------
// WRITE (split into bytes)
// -----------------------------
always_ff @(posedge clk) begin
    if (we) begin
        mem[wr_addr]     <= wr_data[7:0];
        mem[wr_addr + 1] <= wr_data[15:8];
        mem[wr_addr + 2] <= wr_data[23:16];
        mem[wr_addr + 3] <= wr_data[31:24];
    end
end


// -----------------------------
// READ (reconstruct word)
// -----------------------------
assign instr = {
    mem[pc + 3],
    mem[pc + 2],
    mem[pc + 1],
    mem[pc]
};

endmodule
