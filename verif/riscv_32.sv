`timescale 1ns / 1ps

module riscv_32();

    bit clk;
    bit arst_n;

    initial clk = 0;
    always #5ns clk = !clk;


    initial begin
        arst_n = 1'b0;      
        #20ns;             
        arst_n = 1'b1;     
    end

    // Control de la simulación
    initial begin 
        wait (arst_n == 1'b1);        
        repeat (1000) @(posedge clk);   
        $finish;
    end

    microprocessor_top microprocessor_DUT (
        .clk   (clk),
        .arst_n(arst_n)
    );

endmodule
