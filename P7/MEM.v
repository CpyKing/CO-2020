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
	input wire [31:0] PrRD,
	input wire [31:0] CP0_WD,
	input wire overflow,
	input wire [6:2] EM_Exc,
	input wire IntReq,
	input wire M_BD,
	
	output reg [31:0] MW_DM,
	output reg [31:0] MW_AluRe,
	output reg [4:0] MW_WRA,
	output reg [31:0] MW_instruc,
	output reg [31:0] MW_PC,
	
	output wire [31:0] M_Pass,
	output wire [4:0] M_H_WRA,
	output wire [4:0] M_rt,
	output wire [4:0] M_rd,
	
	output wire [31:0] M_WD,
	output wire writeTimer,
	output wire isMtc0,
	output wire [6:2] M_Exc,
	output reg MW_BD
    );
	//	Declaration
	reg [7:0] RAM [65535:0]; //	spare addr by byte
	wire [31:0] Addr = M_AluRe[13:0];
	wire MemWrite;
	wire [31:0] WD;
	wire isByte, isHalf;
	wire PassAPC;
	wire isMfc0;
	wire loadExc, saveExc;
	wire [`NumOfI:0] IBus;
	//	IBus
	IBusOccur MIBO_inMem(.instruc(M_instruc), .IBus(IBus));
	//	Controller
	Controller Con_M(.instruc(M_instruc),
					 .MemWrite(MemWrite),
					 .isByte(isByte),
					 .isHalf(isHalf),
					 .PassAPC(PassAPC),
					 .isMtc0(isMtc0),
					 .isMfc0(isMfc0));
	//
	assign M_WD = WD;
	assign WD = (M_PassSrc == 0) ? M_WTDM : M_W_WTDM;
	assign M_rt = M_instruc[`rt];
	assign M_rd = M_instruc[`rd];
	assign M_H_WRA = M_WRA;
	assign M_Pass = (PassAPC == 1) ? (M_PC + 8) : M_AluRe;
	assign loadExc = (IBus[`lw] && M_AluRe[1:0] != 2'b00) 				||
					 ((IBus[`lh] || IBus[`lhu]) && M_AluRe[0] != 1'b0) 	||
					 (
					  (IBus[`lh] || IBus[`lhu] || IBus[`lb] || IBus[`lbu]) &&
					  (M_AluRe >= 32'h07f00 && M_AluRe <= 32'h07f0b || M_AluRe >= 32'h07f10 && M_AluRe <= 32'h07f1b)
					 ) 													||
					 (IBus[`Load] && overflow) 							||
					 (IBus[`Load] && (M_AluRe >= 32'h3000 && M_AluRe < 32'h07f00 ||
									  M_AluRe > 32'h07f0b && M_AluRe < 32'h07f10 ||
									  M_AluRe > 32'h07f1b));
	assign saveExc = (IBus[`sw] && M_AluRe[1:0] != 2'b00)				||
					 (IBus[`sh] && M_AluRe[0] != 1'b0)					||
					 (
					  (IBus[`sh] || IBus[`sb]) && 
					  (M_AluRe >= 32'h07f00 && M_AluRe <= 32'h07f0b || M_AluRe >= 32'h07f10 && M_AluRe <= 32'h07f1b)
					 )													||
					 (IBus[`Save] && overflow)							||
					 (IBus[`Save] && (M_AluRe == 32'h07f08 ||
									  M_AluRe == 32'h07f18))			||
					 (IBus[`Save] && (M_AluRe >= 32'h3000 && M_AluRe < 32'h07f00 ||
									  M_AluRe > 32'h07f0b && M_AluRe < 32'h07f10 ||
									  M_AluRe > 32'h07f1b));
	assign M_Exc = (loadExc) ? `AdEL : (saveExc) ? `AdEs : EM_Exc;
	assign writeTimer = (MemWrite && M_AluRe >= 32'h07f00 && saveExc == 0);
	always @(posedge clk)begin
		if(IntReq) begin
			MW_instruc <= 0;
			MW_WRA <= 0;
		end
		else begin
			//	Write Date (by word or by byte)
			if(MemWrite && IntReq == 0 && M_AluRe >= 0 && M_AluRe < 32'h03000) begin
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
			MW_DM <= (loadExc == 1) ? 0 : 
					 (isMfc0) ? CP0_WD : 
					 (M_AluRe > 32'h00002fff) ? PrRD :
					 (M_AluRe >= 32'h0 && M_AluRe < 32'h03000) ? 
					 ((isByte == 0) ? {RAM[Addr + 2'b11], RAM[Addr + 2'b10], RAM[Addr + 2'b01], RAM[Addr + 2'b00]} :
									 {24'b0, RAM[Addr]}) : 0;
			//
			MW_AluRe <= M_AluRe;
			MW_WRA <= M_WRA;
			MW_instruc <= M_instruc;
			MW_PC <= M_PC;
			MW_BD <= M_BD;
		end
	end
	
	////////////////	Initial
	integer i;
	initial begin
		MW_DM <= 0;
		MW_AluRe <= 0;
		MW_WRA <= 0;
		MW_instruc <= 0;
		MW_PC <= 0;
		MW_BD <= 0;
		for(i = 0; i< 65536; i = i + 1)begin
			RAM[i] = 0;
		end
	end
	


endmodule
