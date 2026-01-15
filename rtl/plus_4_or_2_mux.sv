`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 09:27:33 AM
// Design Name: 
// Module Name: plus_4_or_2_mux
//////////////////////////////////////////////////////////////////////////////////


module plus_4_or_2_mux(
    input logic sel,
    output logic [2:0] instruction_add
    );
    
always_comb begin   
    case (sel)
        1'b0: begin 
            instruction_add = 3'b100;
        end
        1'b1: begin 
            instruction_add = 3'b010;
        end
        default: instruction_add = 3'b000;
    endcase
end
endmodule
