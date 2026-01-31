typedef enum logic [3:0] {
    OP_UNKNOWN  =   4'b0000,
    OP_RTYPE    =   4'b0001,
    OP_ITYPE    =   4'b0010,
    OP_LOAD     =   4'b0011,
    OP_STORE    =   4'b0100,
    OP_BRANCH   =   4'b0101,
    OP_LUI      =   4'b0110,
    OP_AUIPC    =   4'b0111,
    OP_JAL      =   4'b1000
} opcode_kind_enum;

opcode_kind_enum actual_instruction;

class opcode_decoder; 
    
    function opcode_kind_enum decode(input logic [31:0] instr);
        logic [6:0] opcode;
        opcode = instr[6:0];
        case (opcode)
          7'b0110011: decode = OP_RTYPE;   // R-type
          7'b0010011: decode = OP_ITYPE;   // I-type ALU
          7'b0000011: decode = OP_LOAD;    // Loads
          7'b0100011: decode = OP_STORE;   // Stores
          7'b1100011: decode = OP_BRANCH;  // Branches
          7'b0110111: decode = OP_LUI;     // LUI
          7'b0010111: decode = OP_AUIPC;   // AUIPC
          7'b1101111: decode = OP_JAL;     // JAL
          default:    decode = OP_UNKNOWN;
       endcase
    endfunction 

endclass