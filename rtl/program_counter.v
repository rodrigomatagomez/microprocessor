`timescale 1ns / 1ps
//------------------------------------------------------------------------------
// Module: program_counter
// Description:
//   Program counter (PC) register.
//------------------------------------------------------------------------------

module program_counter #(
    parameter DATA_WIDTH = 32,
    parameter [DATA_WIDTH-1:0] RESET_PC = {DATA_WIDTH{1'b0}}
)(
    input  wire                    clk,
    input  wire                    arst_n,
    input  wire [DATA_WIDTH-1:0]   pc_in,
    output reg  [DATA_WIDTH-1:0]   pc_out
);

// Sequential logic
always @(posedge clk or negedge arst_n) begin
    if (!arst_n)
        pc_out <= RESET_PC;   // Reset PC
    else
        pc_out <= pc_in;
end

endmodule