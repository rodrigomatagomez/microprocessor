module instruction_memory #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 1024
)(
    input  logic [DATA_WIDTH-1:0] pc,
    output logic [DATA_WIDTH-1:0] instr
);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial begin
        $readmemh("program.mem", mem);
    end

    assign instr = mem[pc[11:2]]; //PC is byte-addressed; drop 2 LSBs for 32-bit word indexing

endmodule
