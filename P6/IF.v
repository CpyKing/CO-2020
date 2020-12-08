`timescale 1ns / 1ps
`default_nettype none
module IF(
	input wire clk,
	input wire reset,
	input wire [31:0] F_NPC,
	input wire stall,
	
	output reg [31:0] F_instruc,
	output wire [31:0] F_N_PC,
	output reg [31:0] FD_PC
    );
	//// Declaration
	reg [31:0] PC;
	reg [31:0] ROM [4095:0];
	wire [31:0] Addr = PC - 32'h00003000;
	
	initial begin
		PC <= 32'h00003000;
		$readmemh("code.txt", ROM);
		F_instruc <= 0;
		FD_PC <= 0;
	end
	
	assign F_N_PC = PC;
	
	always @(posedge clk)begin
		if(reset) begin
			PC <= 32'h00003000;
		end	
		else begin
			if(stall != 1) begin			///////	if stall then frozen the F\D  stream reg value
				F_instruc <= ROM[Addr[13:2]];
				PC <= F_NPC;
				FD_PC <= F_N_PC;
			end
		end
	end

endmodule
