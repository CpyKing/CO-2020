`timescale 1ns / 1ps
`default_nettype none
`include "macro.v"
module IF(
	input wire clk,
	input wire reset,
	input wire [31:0] F_NPC,
	input wire stall,
	input wire IntReq,
	input wire eJump,
	
	output reg [31:0] FD_instruc,
	output wire [31:0] F_N_PC,
	output reg [31:0] FD_PC,
	
	output reg [6:2] F_Exc,
	output reg FD_BD,
	output wire if_BD
    );
	//// Declaration
	reg [31:0] F_PC;
	reg [31:0] ROM [4095:0];
	wire [31:0] Addr = F_PC - 32'h00003000;
	wire [6:2] F_Exc_wire;
	
	initial begin
		F_PC <= 32'h00003000;
		$readmemh("code.txt", ROM);
		$readmemh("code_handler.txt", ROM, 1120, 2047);
		FD_instruc <= 0;
		FD_PC <= 0;
		F_Exc <= 0;
		FD_BD <= 0;
	end
	
	assign F_N_PC = F_PC;
	assign F_Exc_wire = ((F_PC[1:0] != 2'b00) || (F_PC < 32'h00003000) || (F_PC > 32'h00004ffc)) ? `AdEL : `INT;
	
	
	Controller Con_F(.instruc(FD_instruc), .BD(if_BD));
	
	always @(posedge clk)begin
		if(reset) begin
			F_PC <= 32'h00003000;
			F_Exc <= 0;
			FD_BD <= 0;
		end	
		else begin
			if(IntReq || (eJump && (!stall)))begin
				FD_instruc <= 0;
				F_Exc <= `INT;
			end 
			else if(!stall)begin
				FD_PC <= F_N_PC;
				FD_instruc <= (F_Exc_wire == `INT) ? ROM[Addr[13:2]] : 32'h0;
				F_Exc <= F_Exc_wire;
				FD_BD <= if_BD;
			end
			
			if(!stall || IntReq)begin
				F_PC <= F_NPC;
			end
			else begin
				F_PC <= F_PC;
			end
		end
	end
	
endmodule
