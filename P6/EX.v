`timescale 1ns / 1ps
`default_nettype none
`include "macro.v"
module EX(
	input wire clk,
	input wire reset,
	input wire [31:0] E_instruc,
	input wire [31:0] E_PC,
	input wire [31:0] E_RD1,
	input wire [31:0] E_RD2,
	input wire [4:0]  E_WRA,
	input wire [31:0] E_Ext,
	input wire [31:0] E_M_Pass,
	input wire [31:0] E_W_WRD,
	input wire [1:0] PassSrcA,
	input wire [1:0] PassSrcB,
	
	output reg [31:0] EM_instruc,
	output reg [31:0] EM_AluRe,
	output reg [31:0] EM_WTDM,
	output reg [4:0]  EM_WRA,
	output reg [31:0] EM_PC,
	
	output wire start,
	output wire [4:0] busyCnt,
	
	output wire [4:0] E_rs,
	output wire [4:0] E_rt
    );
	//	Declaration
	wire [3:0] AluCtrl;
	wire [31:0] AluResult;
	wire AluSrc, isVS;
	wire [31:0] A, B;
	wire [4:0] shift;
	wire ReadHL;
	wire [31:0] HLRe;
	//	Controller
	Controller Con_E(.instruc(E_instruc),
					 .AluCtrl(AluCtrl),
					 .AluSrc(AluSrc),
					 .isVS(isVS),
					 .ReadHL(ReadHL));
	//
	assign shift = (isVS == 1) ? A[4:0] : E_instruc[`shamt];
	assign E_rs = E_instruc[`rs];
	assign E_rt = E_instruc[`rt];
	assign A = (PassSrcA == 2'b00) ? E_RD1 :
			   (PassSrcA == 2'b01) ? E_M_Pass :
			   (PassSrcA == 2'b10) ? E_W_WRD : 0;
	assign B = (AluSrc == 1) ? E_Ext :
			   (PassSrcB == 2'b00) ? E_RD2 :
			   (PassSrcB == 2'b01) ? E_M_Pass :
			   (PassSrcB == 2'b10) ? E_W_WRD : 0;
	assign AluResult = (AluCtrl == `ADD) ? A + B :
					   (AluCtrl == `SUB) ? A - B :
					   (AluCtrl == `AND) ? A & B :
					   (AluCtrl == `OR)  ? A | B :
					   (AluCtrl == `XOR) ? A ^ B :
					   (AluCtrl == `NOR) ? ~(A | B) :
					   (AluCtrl == `STO) ? (($signed(A) < $signed(B)) ? 32'b01 : 0) :
					   (AluCtrl == `STOU)? ((A < B) ? 32'b01 : 0) :
					   (AluCtrl == `LH)  ? {B[15:0], 16'b0} :
					   (AluCtrl == `SLL) ? (B << shift) :
					   (AluCtrl == `SRL) ? (B >> shift) :
					   (AluCtrl == `SRA) ? $signed($signed(B) >>> shift) : 0;
	/////////////	MULT	&	DIV
	MUDI mudi(.clk(clk), .reset(reset),
			  .instruc(E_instruc),
			  .MD_A(A), .MD_B(B),
			  .start(start), .busyCnt(busyCnt),
			  .HLRe(HLRe));
	always @(posedge clk)begin
		EM_instruc <= E_instruc;
		EM_AluRe <= (ReadHL == 1) ? HLRe : AluResult;
		EM_WTDM <= (PassSrcB == 2'b00) ? E_RD2 :
				   (PassSrcB == 2'b01) ? E_M_Pass :
				   (PassSrcB == 2'b10) ? E_W_WRD : 0;
		EM_WRA <= E_WRA;
		EM_PC <= E_PC;
	end
	//////////////	Initial
	initial begin
		EM_instruc <= 0;
		EM_AluRe <= 0;
		EM_WTDM <= 0;
		EM_WRA <= 0;
		EM_PC <= 0;
	end
	
endmodule
