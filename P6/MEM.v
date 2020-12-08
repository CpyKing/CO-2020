`timescale 1ns / 1ps
`default_nettype none
`include "macro.v"
module MEM(
	input wire clk,
	input wire [31:0] M_instruc,
	input wire [31:0] M_PC,
	input wire [31:0] M_AluRe,
	input wire [31:0] M_WTDM,
	input wire [4:0] M_WRA,
	input wire [31:0] M_W_WTDM,
	input wire M_PassSrc,
	
	output reg [31:0] MW_DM,
	output reg [31:0] MW_AluRe,
	output reg [4:0] MW_WRA,
	output reg [31:0] MW_instruc,
	output reg [31:0] MW_PC,
	
	output wire [31:0] M_Pass,
	output wire [4:0] M_H_WRA,
	output wire [4:0] M_rt
    );
	//	Declaration
	reg [7:0] RAM [65535:0]; //	spare addr by byte
	wire [31:0] Addr = M_AluRe;
	wire MemWrite;
	wire [31:0] WD;
	wire isByte, isHalf;
	wire PassAPC;
	//	Controller
	Controller Con_M(.instruc(M_instruc),
					 .MemWrite(MemWrite),
					 .isByte(isByte),
					 .isHalf(isHalf),
					 .PassAPC(PassAPC));
	//
	assign WD = (M_PassSrc == 0) ? M_WTDM : M_W_WTDM;
	assign M_rt = M_instruc[`rt];
	assign M_H_WRA = M_WRA;
	assign M_Pass = (PassAPC == 1) ? (M_PC + 8) : M_AluRe;
	
	always @(posedge clk)begin
		//	Write Date (by word or by byte)
		if(MemWrite) begin
			case(isByte)
				0:
					case(isHalf)
						0:	{RAM[Addr + 2'b11], RAM[Addr + 2'b10], RAM[Addr + 2'b01], RAM[Addr + 2'b00]} = WD;
						1:	{RAM[Addr + 1], RAM[Addr]} = WD[15:0];
					endcase
				1:	RAM[Addr] = WD[7:0];
			endcase
			$display("%d@%h: *%h <= %h", $time, M_PC, {Addr[31:2], 2'b00}, {RAM[{Addr[31:2], 2'b11}], RAM[{Addr[31:2], 2'b10}], RAM[{Addr[31:2], 2'b01}], RAM[{Addr[31:2], 2'b00}]});
		end
		//	Read Data (by word or by byte)
		MW_DM <= (isByte == 0) ? {RAM[Addr + 2'b11], RAM[Addr + 2'b10], RAM[Addr + 2'b01], RAM[Addr + 2'b00]} :
								 {24'b0, RAM[Addr]};
		//
		MW_AluRe <= M_AluRe;
		MW_WRA <= M_WRA;
		MW_instruc <= M_instruc;
		MW_PC <= M_PC;
	end
	
	////////////////	Initial
	integer i;
	initial begin
		MW_DM <= 0;
		MW_AluRe <= 0;
		MW_WRA <= 0;
		MW_instruc <= 0;
		MW_PC <= 0;
		for(i = 0; i< 65536; i = i + 1)begin
			RAM[i] = 0;
		end
	end
	


endmodule
