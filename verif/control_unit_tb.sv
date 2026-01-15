`timescale 1ns / 1ps

module control_unit_tb ();

logic regwrite;
logic memread;
logic memwrite;
logic memtoreg;
logic alusrc;
logic pc_write;
logic [1:0] pc_sel;
logic [2:0] imm_type;
logic [3:0] alucontrol;
logic [31:0] instruction;

initial begin
    // ADDI
    instruction = 32'b00000000101000000000011000010011; // x0 + 10
    #10;

    // BEQ
    instruction = 32'b00000000000001100000110001100011; // branch
    #10;

    // JAL 
    instruction = 32'b11111110110111111111000001101111;
    #10; 

    $finish;    
end

control_unit control_unit_i (
    .opcode   (instruction[6:0]),
    .funct_7  (instruction[31:25]),
    .funct_3  (instruction[14:12]),
    .regwrite (regwrite),
    .memread  (memread),
    .memwrite (memwrite),
    .memtoreg (memtoreg),
    .alusrc   (alusrc),
    .pc_write (pc_write),
    .pc_sel   (pc_sel),
    .imm_type (imm_type),
    .alucontrol(alucontrol)
);

endmodule
