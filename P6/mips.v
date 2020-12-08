`timescale 1ns / 1ps
`default_nettype none
`include "macro.v"
module mips(
	input wire clk,
	input wire reset
    );
	////////////////	IF
	wire [31:0] FD_instruc;
	wire [31:0] PC;
	wire [31:0] NPC_out, FD_PC;
	wire stall;
	wire start;
	wire [4:0] busyCnt;
	IF F(.clk(clk), .reset(reset),
		 .F_NPC(NPC_out),
		 .stall(stall),
		 .F_instruc(FD_instruc),
		 .F_N_PC(PC),
		 .FD_PC(FD_PC));
	////////////////	ID
	wire [31:0] WD_WRD, WD_PCWhenWrite;
	wire [4:0] WD_WRA;
	wire PassSrcRD1, PassSrcRD2;
	wire [15:0] D_N_imm16;
	wire [25:0] D_N_imm26;
	wire [31:0] D_N_RD1;
	wire branchJump, immJump, regJump;
	wire [31:0] DE_RD1, DE_RD2, DE_instruc, DE_Ext, DE_PC;
	wire [4:0] DE_WRA;
	wire [4:0] D_rs, D_rt;
	wire [31:0] M_Pass;
	ID id(.clk(clk), .reset(reset),
		  .D_instruc(FD_instruc), .D_WRA(WD_WRA), .D_WRD(WD_WRD), .D_PC(FD_PC), .D_PCWhenWrite(WD_PCWhenWrite),
		  .PassSrcRD1(PassSrcRD1), .PassSrcRD2(PassSrcRD2), .D_M_Pass(M_Pass), .stall(stall),
		  .D_imm16(D_N_imm16), .D_imm26(D_N_imm26), .D_RD1(D_N_RD1), .branchJump(branchJump), .immJump(immJump), .regJump(regJump),
		  .DE_RD1(DE_RD1), .DE_RD2(DE_RD2), .DE_instruc(DE_instruc), .DE_WRA(DE_WRA), .DE_Ext(DE_Ext), .DE_PC(DE_PC),
		  .D_rs(D_rs), .D_rt(D_rt));
	////////////////////	NPC
	NPC npc(.branchJump(branchJump), .immJump(immJump), .regJump(regJump),
			.regValue(D_N_RD1), .imm16(D_N_imm16), .imm26(D_N_imm26), .PC(PC),
			.NPC(NPC_out));
	////////////////////	EX
	wire [31:0] W_E_WRD;
	wire [31:0] EM_instruc, EM_AluRe, EM_WTDM;
	wire [4:0] EM_WRA;
	wire [31:0] EM_PC;
	wire [4:0] E_rs, E_rt;
	wire [1:0] PassSrcA, PassSrcB;
	EX ex(.clk(clk), .reset(reset),
		  .E_instruc(DE_instruc), .E_PC(DE_PC), .E_RD1(DE_RD1), .E_RD2(DE_RD2), .E_WRA(DE_WRA), .E_Ext(DE_Ext),
		  .E_M_Pass(M_Pass), .E_W_WRD(W_E_WRD), .PassSrcA(PassSrcA), .PassSrcB(PassSrcB),
		  .EM_instruc(EM_instruc), .EM_AluRe(EM_AluRe), .EM_WTDM(EM_WTDM), .EM_WRA(EM_WRA), .EM_PC(EM_PC),
		  .E_rs(E_rs), .E_rt(E_rt),
		  .start(start), .busyCnt(busyCnt));
	////////////////////	MEM
	wire [31:0] W_M_WTDM;
	wire PassSrc;
	wire [31:0] MW_DM, MW_AluRe, MW_instruc, MW_PC;
	wire [4:0] MW_WRA;
	wire [4:0] M_H_WRA, M_rt;
	MEM mem(.clk(clk),
			.M_instruc(EM_instruc), .M_PC(EM_PC), .M_AluRe(EM_AluRe), .M_WTDM(EM_WTDM), .M_WRA(EM_WRA),
			.M_W_WTDM(W_M_WTDM), .M_PassSrc(PassSrc),
			.MW_DM(MW_DM), .MW_AluRe(MW_AluRe), .MW_WRA(MW_WRA), .MW_instruc(MW_instruc), .MW_PC(MW_PC),
			.M_Pass(M_Pass), .M_H_WRA(M_H_WRA), .M_rt(M_rt));
	////////////////////	WB
	assign W_E_WRD = WD_WRD;
	assign W_M_WTDM = WD_WRD;
	WB wb(.W_instruc(MW_instruc), .W_PC(MW_PC), .W_DM(MW_DM), .W_AluRe(MW_AluRe), .W_WRA(MW_WRA),
		  .WD_WRA(WD_WRA), .WD_WRD(WD_WRD), .WD_PCWhenWrite(WD_PCWhenWrite));
	////////////////////	HAZARD
	wire [`NumOfI:0] DIBus, EIBus, MIBus;
	IBusOccur DIBusOccur(.instruc(FD_instruc), .IBus(DIBus));
	IBusOccur EIBusOccur(.instruc(DE_instruc), .IBus(EIBus));
	IBusOccur MIBusOccur(.instruc(EM_instruc), .IBus(MIBus));
	Hazard_Unit HU(.clk(clk),
				   .DIBus(DIBus), .EIBus(EIBus), .MIBus(MIBus),
				   .D_rs(D_rs), .D_rt(D_rt),
				   .E_rs(E_rs), .E_rt(E_rt), .E_WRA(DE_WRA),
				   .start(start), .busyCnt(busyCnt),
				   .M_rt(M_rt), .M_WRA(M_H_WRA),
				   .W_WRA(MW_WRA),
				   .stall(stall), .PassSrcRD1_D(PassSrcRD1), .PassSrcRD2_D(PassSrcRD2), .PassSrcA_E(PassSrcA), .PassSrcB_E(PassSrcB), .PassSrc_M(PassSrc));
				   
endmodule
