`timescale 1ns/1ps

module adder_acc (
    input  logic signed [`ACC_WIDTH-1:0] a,
    input  logic signed [`ACC_WIDTH-1:0] b,
    output logic signed [`ACC_WIDTH-1:0] sum
);
    assign sum = a + b;
endmodule
