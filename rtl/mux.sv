module mux #( parameter WIDTH = 32)(
    input  logic [WIDTH-1:0] in1,
    input  logic [WIDTH-1:0] in2,      // array of N inputs
    input  logic             sel,      // select
    output logic [WIDTH-1:0] out       // mux output
);
    assign out = (sel) ? in1 : in2; //0 = in_2
endmodule

