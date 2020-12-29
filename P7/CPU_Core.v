`timescale 1ns / 1ps
`default_nettype none
`include "macro.v"
module CPU_Core(
	input wire clk,
	input wire reset,
	
	input wire interrupt,
	
	input wire [31:0] PrRD,
	input wire IRQ_0,
	input wire IRQ_1,
	
	output wire [31:0] EM_AluRe,
	output wire [31:0] M_WD,
	output wire writeTimer,
	output wire [31:0] addr
    );
	////////////////	IF
	wire [31:0] FD_instruc;
	wire [31:0] PC;
	wire [31:0] NPC_out, FD_PC;
	wire stall;
	wire start;
	wire [4:0] busyCnt;
	wire [6:2] F_Exc;
	wire IntReq, eJump, FD_BD, F_BD;
	IF F(.clk(clk), .reset(reset),
		 .F_NPC(NPC_out),
		 .stall(stall), .eJump(eJump),
		 .FD_instruc(FD_instruc),
		 .F_N_PC(PC),
		 .FD_PC(FD_PC),
		 .F_Exc(F_Exc), .IntReq(IntReq), .FD_BD(FD_BD), .if_BD(F_BD));
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
	wire [6:2] D_Exc;
	wire DE_BD;
	
	ID id(.clk(clk), .reset(reset),
		  .D_instruc(FD_instruc), .D_WRA(WD_WRA), .D_WRD(WD_WRD), .D_PC(FD_PC), .D_PCWhenWrite(WD_PCWhenWrite),
		  .PassSrcRD1(PassSrcRD1), .PassSrcRD2(PassSrcRD2), .D_M_Pass(M_Pass), .stall(stall), .FD_Exc(F_Exc),
		  .IntReq(IntReq), .D_BD(FD_BD),
		  .D_imm16(D_N_imm16), .D_imm26(D_N_imm26), .D_RD1(D_N_RD1), .branchJump(branchJump), .immJump(immJump), .regJump(regJump),
		  .DE_RD1(DE_RD1), .DE_RD2(DE_RD2), .DE_instruc(DE_instruc), .DE_WRA(DE_WRA), .DE_Ext(DE_Ext), .DE_PC(DE_PC),
		  .D_rs(D_rs), .D_rt(D_rt), .D_Exc(D_Exc), .eJump(eJump), .DE_BD(DE_BD));
	////////////////////	NPC
	wire [31:0] EPC;
	wire [31:0] PassEretPc;
	NPC npc(.branchJump(branchJump), .immJump(immJump), .regJump(regJump), .eJump(eJump), .IntReq(IntReq),
			.regValue(D_N_RD1), .imm16(D_N_imm16), .imm26(D_N_imm26), .PC(PC), .EPC(PassEretPc),
			.NPC(NPC_out));
	////////////////////	EX
	wire [31:0] W_E_WRD;
	wire [31:0] EM_instruc, EM_WTDM;
	wire [4:0] EM_WRA;
	wire [31:0] EM_PC;
	wire [4:0] E_rs, E_rt, E_rd;
	wire [1:0] PassSrcA, PassSrcB;
	wire [6:2] E_Exc;
	wire overflow, EM_BD;
	EX ex(.clk(clk), .reset(reset),
		  .E_instruc(DE_instruc), .E_PC(DE_PC), .E_RD1(DE_RD1), .E_RD2(DE_RD2), .E_WRA(DE_WRA), .E_Ext(DE_Ext),
		  .E_M_Pass(M_Pass), .E_W_WRD(W_E_WRD), .PassSrcA(PassSrcA), .PassSrcB(PassSrcB), .DE_Exc(D_Exc),
		  .IntReq(IntReq), .E_BD(DE_BD), .stall(stall),
		  .EM_instruc(EM_instruc), .EM_AluRe(EM_AluRe), .EM_WTDM(EM_WTDM), .EM_WRA(EM_WRA), .EM_PC(EM_PC),
		  .E_rs(E_rs), .E_rt(E_rt), .E_rd(E_rd),
		  .start(start), .busyCnt(busyCnt), .E_Exc(E_Exc), .overflow(overflow), .EM_BD(EM_BD));
	////////////////////	MEM
	wire [31:0] W_M_WTDM;
	wire PassSrc;
	wire [31:0] MW_DM, MW_AluRe, MW_instruc, MW_PC;
	wire [4:0] MW_WRA;
	wire [4:0] M_H_WRA, M_rt, M_rd;
	wire isMtc0;
	wire [6:2] M_Exc;
	wire [31:0] CP0_WD;
	wire MW_BD;
	//assign addr = EM_PC;
	MEM mem(.clk(clk),
			.M_instruc(EM_instruc), .M_PC(EM_PC), .M_AluRe(EM_AluRe), .M_WTDM(EM_WTDM), .M_WRA(EM_WRA),
			.M_W_WTDM(W_M_WTDM), .M_PassSrc(PassSrc), .PrRD(PrRD), .CP0_WD(CP0_WD), .EM_Exc(E_Exc), .overflow(overflow),
			.IntReq(IntReq), .M_BD(EM_BD),
			.MW_DM(MW_DM), .MW_AluRe(MW_AluRe), .MW_WRA(MW_WRA), .MW_instruc(MW_instruc), .MW_PC(MW_PC),
			.M_Pass(M_Pass), .M_H_WRA(M_H_WRA), .M_rt(M_rt), .M_rd(M_rd),
			.M_WD(M_WD), .writeTimer(writeTimer), .M_Exc(M_Exc), .isMtc0(isMtc0), .MW_BD(MW_BD));
	////////////////////	WB
	assign W_E_WRD = WD_WRD;
	assign W_M_WTDM = WD_WRD;
	wire W_isEret;
	WB wb(.W_instruc(MW_instruc), .W_PC(MW_PC), .W_DM(MW_DM), .W_AluRe(MW_AluRe), .W_WRA(MW_WRA),
		  .IntReq(IntReq),
		  .WD_WRA(WD_WRA), .WD_WRD(WD_WRD), .WD_PCWhenWrite(WD_PCWhenWrite),.W_isEret(W_isEret));
	////////////////////	HAZARD
	wire [`NumOfI:0] DIBus, EIBus, MIBus;
	wire [31:0] CP0_EPC = EPC;
	IBusOccur DIBusOccur(.instruc(FD_instruc), .IBus(DIBus));
	IBusOccur EIBusOccur(.instruc(DE_instruc), .IBus(EIBus));
	IBusOccur MIBusOccur(.instruc(EM_instruc), .IBus(MIBus));
	Hazard_Unit HU(.clk(clk),
				   .DIBus(DIBus), .EIBus(EIBus), .MIBus(MIBus),
				   .D_rs(D_rs), .D_rt(D_rt),
				   .E_rs(E_rs), .E_rt(E_rt), .E_rd(E_rd), .E_WRA(DE_WRA),
				   .start(start), .busyCnt(busyCnt),
				   .M_rt(M_rt), .M_rd(M_rd), .M_WRA(M_H_WRA), .M_WD(M_WD),
				   .W_WRA(MW_WRA),
				   .CP0_EPC(EPC),
				   .stall(stall), .PassSrcRD1_D(PassSrcRD1), .PassSrcRD2_D(PassSrcRD2), .PassSrcA_E(PassSrcA), .PassSrcB_E(PassSrcB), .PassSrc_M(PassSrc),
				   .PassEretPc(PassEretPc));
	////////////////////	CP0
	
	assign	addr = (EM_PC || M_Exc) ? EM_PC :
				   (DE_PC || E_Exc) ? DE_PC :
				   (FD_PC || D_Exc) ? FD_PC :
				   (PC) ? PC : 0;
	wire marcoBD = (EM_PC || M_Exc) ? EM_BD :
				   (DE_PC || E_Exc) ? DE_BD :
				   (FD_PC || D_Exc) ? FD_BD :
				   (PC) ? F_BD : 0;
	wire [15:10] HWInt = {3'b0,interrupt,IRQ_1,IRQ_0};
	wire [6:2] cp0_ExcCode = (|HWInt) ? `INT : M_Exc;
	CP0	cp0(.clk(clk), .reset(reset),
			.A1(EM_instruc[`rd]), .A2(EM_instruc[`rd]), .DIn(M_WD),
			.PC(addr), .ExcCode(cp0_ExcCode), .HWInt(HWInt),
			.WE(isMtc0), .EXLSet(IntReq), .EXLClr(W_isEret), .BD(marcoBD),
			.IntReq(IntReq), .EPC(EPC), .DOut(CP0_WD));
			
endmodule
