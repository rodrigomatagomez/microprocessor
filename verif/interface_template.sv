`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Mifral
// Engineer:
//
// Design Name: semicolab
// Module Name: interface_ip_tile
//
//////////////////////////////////////////////////////////////////////////////////

interface interface_ip_tile(input logic clk, input logic arst_n);

// CSR parameters
parameter CSR_IN_WIDTH = 16;
parameter CSR_OUT_WIDTH = 16;
parameter REG_WIDTH = 32;

// Declaration of signals used by user tile
bit [CSR_IN_WIDTH - 1 : 0] csr_in;
bit [REG_WIDTH - 1 : 0] data_reg_a;
bit [REG_WIDTH - 1 : 0] data_reg_b;
logic [CSR_OUT_WIDTH - 1 : 0] csr_out;
logic csr_in_re;
logic csr_out_we;
logic [REG_WIDTH - 1 : 0] data_reg_c;

// Declaration of signals used by testbench only (can only be accessed by interface tasks/functions)
logic [CSR_OUT_WIDTH - 1 : 0] csr_out_r;
bit csr_in_we;
bit [CSR_IN_WIDTH - 1 : 0] csr_in_wdata;
bit csr_out_re;

// This modport should be used by user to connect with his/her tile logic
modport user_tile_modport(
	input csr_in, data_reg_a, data_reg_b,
	output csr_in_re, csr_out, csr_out_we, data_reg_c
);

// This task can be used to assign a value to data_reg_a user tile input
task write_data_reg_a(logic [REG_WIDTH - 1 : 0] data);
	@(posedge clk);
	data_reg_a <= data;
endtask

// This task can be used to assign a value to data_reg_b user tile input
task write_data_reg_b(logic [REG_WIDTH - 1 : 0] data);
	@(posedge clk);
	data_reg_b <= data;
endtask

// This task can be used to read the current value of user tile output data_reg_c
function logic [REG_WIDTH - 1 : 0] read_data_reg_c();
	return data_reg_c;
endfunction

// This task can be used to read user tile output csr_out, this will clear all clear on read csr_out bits
task read_csr_out(output logic [CSR_OUT_WIDTH - 1 : 0] csr_out_data);
	csr_out_data <= csr_out_r;
	csr_out_re <= 1'b1;
	@(posedge clk);
	csr_out_re <= 1'b0;
endtask

// This task can be used to write user tile input csr_in
task write_csr_in(logic [CSR_IN_WIDTH - 1 : 0] csr_in_data);
	csr_in_wdata <= csr_in_data;
	csr_in_we <= 1'b1;
	@(posedge clk);
	csr_in_we <= 1'b0;
endtask

// This procedural block emulates the csr_out register
always_ff@(posedge clk, negedge arst_n) begin
	if(!arst_n) begin
		csr_out_r <= {CSR_OUT_WIDTH{1'b0}};
	end else begin
	if(csr_out_we) // Writing is taking priority over clear on read
	csr_out_r <= csr_out;
	else if(csr_out_re)
	csr_out_r[3 : 0] <= 4'd0; // 4 Least Significant Bits are clear on read, so we have to clear when reading
	end
end

// This procedural block emulates the csr_in register
always@(posedge clk, negedge arst_n) begin
	if(~arst_n) begin
	csr_in <= {CSR_IN_WIDTH{1'b0}};
	end else begin
	csr_in[CSR_IN_WIDTH - 1 : CSR_IN_WIDTH - 4] <= 4'd0; // 4 Most Significant Bits are single pulse, so we have to clear every clock cycle except when we write
	if(csr_in_we) // Writing is taking priority over clear on read
	csr_in <= csr_in_wdata;
	else if(csr_in_re)
	csr_in[3 : 0] <= 4'd0; // 4 Least Significant Bits are clear on read, so we have to clear when reading
	end
end

endinterface
