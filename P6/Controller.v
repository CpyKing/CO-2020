`timescale 1ns / 1ps
`default_nettype none
`include "macro.v"
module Controller(
	input wire [31:0] instruc,
	
	output wire [`NumOfI:0] IBus,
	output wire isBranch,
	output wire immJump,
	output wire regJump,
	output wire [1:0] RegDst,
	output wire ExtOp,
	output wire [3:0] AluCtrl,
	output wire AluSrc,
	output wire MemWrite,
	output wire isByte,
	output wire isHalf,
	output wire [1:0] MemtoReg,
	output wire [1:0] HBExtOp,
	output wire PassAPC,
	output wire isVS,	// is variable shift ?
	output wire isMU,
	output wire isDI,
	output wire MUDI,
	output wire isSigned,
	output wire ReadHL,
	output wire WriteHL,
	output wire WriteHi,
	output wire ReadHi
    );
	
	reg  add, addu, sub, subu, And, Or, Xor, Nor, slt, sltu, sll, srl, sra, sllv, srlv, srav,
		 mult, multu, div, divu, mfhi, mflo, mthi, mtlo,
		 jr, jalr,
		 addi, addiu, andi, ori, xori, lui, slti, sltiu,
		 lw, lb, lbu, lh, lhu,
		 sw, sb, sh,
		 beq, bgez, bgtz, blez, bltz, bne,
		 j, jal, 
		 nop;
	wire I_R, I_I, Sft, VSft, Load, Save, Branch;
	wire [5:0] OpCode = instruc[`OpCode];
	wire [5:0] Func   = instruc[`Func];
	//	IBusOccur-Decoder
	IBusOccur ConIBusOccur(.instruc(instruc), .IBus(IBus));
	//	Sort instruction
	assign I_R = IBus[`I_R];
	assign Sft = IBus[`Sft];
	assign VSft	= IBus[`VSft];
	assign I_I = IBus[`I_I];
	assign Load	= IBus[`Load];
	assign Save	= IBus[`Save];
	assign Branch = IBus[`Branch];
	
	//	Decoder	 
	always @(*) begin
		//	R
		add  = IBus[`add];
		addu = IBus[`addu];
		sub  = IBus[`sub];
		subu = IBus[`subu];
		And  = IBus[`And];
		Or   = IBus[`Or];
		Xor	 = IBus[`Xor];
		Nor  = IBus[`Nor];
		slt  = IBus[`slt];
		sltu = IBus[`sltu];
		sll	 = IBus[`sll];
		srl  = IBus[`srl];
		sra  = IBus[`sra];
		sllv = IBus[`sllv];
		srlv = IBus[`srlv];
		srav = IBus[`srav];
		jr   = IBus[`jr];
		jalr = IBus[`jalr];
		
		mult = IBus[`mult];
		multu= IBus[`multu];
		div  = IBus[`div];
		divu = IBus[`divu];
		mfhi = IBus[`mfhi];
		mflo = IBus[`mflo];
		mthi = IBus[`mthi];
		mtlo = IBus[`mtlo];
		//	I
		addi = IBus[`addi];
		addiu= IBus[`addiu];
		andi = IBus[`andi];
		ori  = IBus[`ori];
		xori = IBus[`xori];
		lui  = IBus[`lui];
		slti = IBus[`slti];
		sltiu= IBus[`sltiu];
		
		lw  = IBus[`lw];
		lb  = IBus[`lb];
		lbu = IBus[`lbu];
		lh = IBus[`lh];
		lhu = IBus[`lhu];
		
		sw  = IBus[`sw];
		sb  = IBus[`sb];
		sh = IBus[`sh];
		
		beq = IBus[`beq];
		bgez= IBus[`bgez];
		bgtz= IBus[`bgtz];
		blez= IBus[`blez];
		bltz= IBus[`bltz];
		bne = IBus[`bne];
		// 	J
		jal = IBus[`jal];
		j   = IBus[`j];
	end
	
	assign isBranch = Branch;
	assign immJump = jal || j;
	assign regJump = jr || jalr;
	assign RegDst = {I_R || Sft || VSft ||
					 jalr || jal ||
					 mfhi || mflo, 
					 
					 I_I ||
					 Load || 
					 jal};
	assign ExtOp = Load || 
				   Save || 
				   Branch || 
				   addi || addiu || slti || sltiu;
	assign AluCtrl = (sub || subu) ? `SUB :
					 (And || andi) ? `AND :
					 (Or || ori)   ? `OR  :
					 (Xor|| xori)  ? `XOR :
					 (Nor)		   ? `NOR :
					 (lui)		   ? `LH  :
					 (slt || slti) ? `STO :
					 (sltu || sltiu) ? `STOU:
					 (sll || sllv) ? `SLL :
					 (srl || srlv) ? `SRL :
					 (sra || srav) ? `SRA : `ADD;
	assign AluSrc =  I_I ||
					 Load ||
					 Save;
					 
	assign MemWrite = Save;
	assign isByte = lb || lbu || sb;
	assign isHalf = lh || lhu || sh;
	assign MemtoReg = {jalr || jal || lb || lh || lbu || lhu, 
					   jalr || jal || lw};
	assign HBExtOp = {lh || lhu,
					  lb || lh};
	assign PassAPC = jal || jalr;
	assign isVS = VSft;
	
	assign isMU = mult || multu;
	assign isDI = div || divu;
	assign MUDI = div || divu || mult || multu;
	assign isSigned = div || mult;
	assign ReadHL = mfhi || mflo;
	assign WriteHL= mthi || mtlo;
	assign WriteHi= mthi;
	assign ReadHi = mfhi;
endmodule
