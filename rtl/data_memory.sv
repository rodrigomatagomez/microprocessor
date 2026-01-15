`timescale 1ns / 1ps
module data_memory #(
    parameter DATA_WIDTH = 32,      // Ancho de instruccion / dato
    parameter ADDR_WIDTH = 32,      // Ancho de dirección del PC
    parameter MEM_DEPTH  = 1024        // Profundidad (4 renglones: 0,1,2,3)
    )(

    input logic clk,
    input logic w_en,             // Write Enable desde CU
    input logic [ADDR_WIDTH-1:0] wr_addr,       // Address
    input logic [DATA_WIDTH-1:0] data_in,      // Write data de memoria de datos
    output logic [DATA_WIDTH-1:0] rd_data      // Read Data (Dato de salida) de memoria de datos
);

    // Memoria de 32 bits y 1024 renglones
    logic [DATA_WIDTH-1:0] ram [0:MEM_DEPTH-1]; 

    // Lectura debe de ser combinacional
    assign rd_data = ram[wr_addr[ADDR_WIDTH-1:2]];

    // 1. Inicialización (Limpieza)
    initial begin
        for (int i=0; i<MEM_DEPTH; i++) 
            ram[i] = {DATA_WIDTH{1'b0}};    
    end
    
    // Escritura debe de ser secuencial
    always_ff @(posedge clk) begin
        if (w_en) begin
            ram[wr_addr[ADDR_WIDTH-1:2]] <= data_in;         //si WE es 1, se escribe en la ram el valor
        end
    end
    
    

endmodule
