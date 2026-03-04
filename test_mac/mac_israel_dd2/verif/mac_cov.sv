// mac_cov.sv - Adaptado para el MAC de Israel
module mac_cov (
    input logic clk,
    input logic rst_n,
    input logic signed [`DATA_WIDTH-1:0] operand_a,
    input logic signed [`DATA_WIDTH-1:0] operand_b,
    input logic [1:0] state,
    input logic signed [`ACC_WIDTH-1:0] product_out,
    input logic ready
);

    // COVERGROUP PARA EL MAC
    covergroup cg_mac @(posedge clk iff rst_n);
        option.per_instance = 1;
        option.name = "Cobertura_Funcional_MAC";

        // Cobertura de Operandos (Signos y Casos Esquina) CORNERS DE PKG
        cp_a: coverpoint operand_a {
            bins zero      = {0};
            bins pos_small = {[1 : `THRESH_P]};
            bins pos_large = {[`THRESH_P + 1 : `MAX_POS - 1]};
            bins neg_small = {[`THRESH_N : -1]};
            bins neg_large = {[`MAX_NEG + 1 : `THRESH_N - 1]};
            bins max_pos   = {`MAX_POS};
            bins max_neg   = {`MAX_NEG};
        }

        cp_b: coverpoint operand_b {
            bins zero      = {0};
            bins pos_small = {[1 : `THRESH_P]};
            bins pos_large = {[`THRESH_P + 1 : `MAX_POS - 1]};
            bins neg_small = {[`THRESH_N : -1]};
            bins neg_large = {[`MAX_NEG + 1 : `THRESH_N - 1]};
            bins max_pos   = {`MAX_POS};
            bins max_neg   = {`MAX_NEG};
        }

        // Cobertura de la FSM (Booth)
        cp_fsm: coverpoint state {
            bins IDLE   = {2'b00};
            bins LOAD   = {2'b01};
            bins CALC   = {2'b10};
            bins DONE   = {2'b11};
            illegal_bins otros = default; 
        }

        // COMBINACIONES (CROSS COVERAGE)
        a_x_b: cross cp_a, cp_b;

    endgroup

    // Instancia del grupo
    cg_mac cg_inst = new();

endmodule

bind mac_top mac_cov u_mac_cov (
    .clk(clk),
    .rst_n(rst_n),
    .operand_a(m_in),
    .operand_b(q_in),
    .product_out(product),
    .ready(ready),
    .state(multiplicador_inst.control_unit.state) 
);
