interface mac_if (input logic clk, input logic rst_n);
    logic start, ready;
    logic [`DATA_WIDTH-1:0] m_in, q_in;
    logic [`ACC_WIDTH-1:0] product;

    // Inicialización
    task automatic initialize();
        start <= 0; m_in <= 0; q_in <= 0;
        @(posedge clk);
    endtask

    // Driver
    task automatic compute(input logic [`DATA_WIDTH-1:0] val_m, input logic [`DATA_WIDTH-1:0] val_q);
        @(posedge clk);
        start <= 1; m_in <= val_m; q_in <= val_q;
        @(posedge clk);
        start <= 0;
        wait(ready == 1'b1);
        repeat(2) @(posedge clk);
    endtask
endinterface