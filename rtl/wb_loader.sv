`timescale 1ns / 1ps

module wb_loader #(
    parameter int AW = 32,
    parameter int DW = 32
)(
    input  logic            clk,
    input  logic            rst_n,

    // UART CONTROL
    input  logic            load_new,

    // Command interface
    input  logic [AW-1:0]   cmd_addr,
    input  logic [DW-1:0]   cmd_wdata,
    input  logic [3:0]      cmd_sel,
    input  logic            cmd_we,
    input  logic            cmd_valid,
    output logic            cmd_ready,

    // Response interface
    output logic [DW-1:0]   rsp_rdata,
    output logic            rsp_valid,

    // To instruction memory
    output logic            imem_wr_en,
    output logic [AW-1:0]   imem_wr_addr,
    output logic [DW-1:0]   imem_wr_data,
    output logic [3:0]      imem_wr_sel,

    // Status
    output logic            loader_busy,
    output logic            load_done,   // Flag when load is done
    output logic            loaded       // state to rv32i start running the program 
);

    //Selected instruction to finish the programs 
    localparam logic [31:0] DONE_INST = 32'hCAFE_BABE;

    typedef enum logic [1:0] {
        S_IDLE  = 2'b00,
        S_WRITE = 2'b01,
        S_RESP  = 2'b10
    } state_t;

    state_t state, state_n;

    // latch command acepted 
    logic [AW-1:0] addr_q;
    logic [DW-1:0] wdata_q;
    logic [3:0]    sel_q;
    logic          we_q;
    logic          end_q;

    logic end_cmd;

    // Defined final instr
    assign end_cmd = cmd_we && (cmd_wdata == DONE_INST) && (cmd_sel == 4'b1111);

    //--------------------------------------------------------------------------
    // Next-state logic + outputs
    //--------------------------------------------------------------------------
    always_comb begin
        // Defaults
        cmd_ready    = 1'b0;
        rsp_valid    = 1'b0;
        rsp_rdata    = '0;

        imem_wr_en   = 1'b0;
        imem_wr_addr = addr_q;
        imem_wr_data = wdata_q;
        imem_wr_sel  = sel_q;

        loader_busy  = 1'b1;

        state_n      = state;

        unique case (state)
            S_IDLE: begin
                loader_busy = 1'b0;
                cmd_ready   = ~loaded; //Do not accpet new loads if its already loaded

                if (cmd_valid && cmd_ready) begin
                    state_n = S_WRITE;
                end
            end

            S_WRITE: begin
                //  write to IMEM
                imem_wr_en   = we_q;
                imem_wr_addr = addr_q;
                imem_wr_data = wdata_q;
                imem_wr_sel  = sel_q;

                state_n = S_RESP;
            end

            S_RESP: begin
                rsp_valid = 1'b1;
                rsp_rdata = '0;
                state_n   = S_IDLE;
            end

            default: begin
                state_n = S_IDLE;
            end
        endcase
    end

    //--------------------------------------------------------------------------
    // Sequential logic
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            addr_q    <= '0;
            wdata_q   <= '0;
            sel_q     <= 4'b0000;
            we_q      <= 1'b0;
            end_q     <= 1'b0;
            load_done <= 1'b0;
            loaded    <= 1'b0;
        end else begin
            state <= state_n;

            // default
            load_done <= 1'b0;

            // New program loads
            if (load_new) begin
                loaded <= 1'b0;
            end

            // when a command is acepted 
            if (state == S_IDLE && cmd_valid && cmd_ready) begin
                addr_q  <= cmd_addr;
                wdata_q <= cmd_wdata;
                sel_q   <= cmd_sel;
                we_q    <= cmd_we;
                end_q   <= end_cmd;
            end

            // when the program is loaded 
            if (state == S_WRITE && end_q) begin
                load_done <= 1'b1;
                loaded    <= 1'b1;
            end
        end
    end

endmodule
