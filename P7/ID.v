`timescale 1ns / 1ps
`default_nettype none
`include "macro.v"
module ID(
	input wire clk,
	input wire reset,
	input wire [31:0] D_instruc,
	input wire [4:0] D_WRA,
	input wire [31:0] D_WRD,
	input wire PassSrcRD1, PassSrcRD2,// pass data select
	input wire [31:0] D_PC,
	input wire [31:0] D_PCWhenWrite,
	input wire [31:0] D_M_Pass,	// passing data from M
	input wire stall,
	input wire [6:2] FD_Exc,
	input wire IntReq,
	input wire D_BD,
	
	output wire [`Imm16] D_imm16,// to NPC
	output wire [`Imm26] D_imm26,// to NPC
	output wire [31:0] D_RD1,	// to NPC regValue
	output wire branchJump, immJump, regJump, // to NPC
	output reg [31:0] DE_RD1,
	output reg [31:0] DE_RD2,
	output reg [31:0] DE_instruc,
	output reg [4:0] DE_WRA,
	output reg [31:0] DE_Ext,
	output reg [31:0] DE_PC,
	
	output wire [4:0] D_rs,	//to H
	output wire [4:0] D_rt,	//to H
	
	output reg [6:2] D_Exc,
	output wire eJump,
	output reg DE_BD
    );
	//	Declaration
	reg [31:0] GRF [31:0];
	parameter ra = 5'd31;
	wire [`NumOfI:0] IBus;
	wire [31:0] GRF_RD1 = GRF[D_instruc[`rs]];
	wire [31:0] GRF_RD2 = GRF[D_instruc[`rt]];
	wire isBranch;
	wire cmpTrue;
	wire ExtOp;
	wire [1:0] RegDst;
	wire [31:0] RD1, RD2;
	wire [6:2] D_Exc_wire;
	wire InsMatch;
	//	Controller
	Controller Con_D(.instruc(D_instruc), 
					 .IBus(IBus),
					 .ExtOp(ExtOp),
					 .RegDst(RegDst),
					 .isBranch(isBranch),
					 .immJump(immJump),
					 .regJump(regJump),
					 .InsMatch(InsMatch),
					 .eJump(eJump));
	//	CMP
	CMP cmp(.IBus(IBus), .A(RD1), .B(RD2), .cmpTrue(cmpTrue));
	//
	//	Initial
	integer i;
	initial begin
		for(i=0; i<32; i=i+1)begin
			GRF[i] <= 0;
		end
		DE_RD1 <= 0;
		DE_RD2 <= 0;
		DE_instruc <= 0;
		DE_WRA <= 0;
		DE_Ext <= 0;
		DE_PC <= 0;
		D_Exc <= 0;
		DE_BD <= 0;
	end
	assign D_imm16 = D_instruc[`Imm16];
	assign D_imm26 = D_instruc[`Imm26];
	assign D_RD1 = RD1;
	assign RD1 = (PassSrcRD1 == 1) ? D_M_Pass : (D_WRA == D_rs && D_rs != 0) ? D_WRD : GRF_RD1;
	assign RD2 = (PassSrcRD2 == 1) ? D_M_Pass : (D_WRA == D_rt && D_rt != 0) ? D_WRD : GRF_RD2;
	assign branchJump = cmpTrue && isBranch;
	assign D_rs = D_instruc[`rs];
	assign D_rt = D_instruc[`rt];
	
	assign D_Exc_wire = (InsMatch == 1) ? FD_Exc : `RI;
	
	/*always @(negedge clk) begin	//store data when negedge
		if(D_WRA != 0) begin
				GRF[D_WRA] <= D_WRD;
				$display("%d@%h: $%d <= %h", $time, D_PCWhenWrite, D_WRA, D_WRD);
		end
	end*/
	always @(posedge clk) begin
		//	Write GRF
		if(D_WRA != 0) begin
			GRF[D_WRA] <= D_WRD;
			$display("%d@%h: $%d <= %h", $time, D_PCWhenWrite, D_WRA, D_WRD);
		end
	end
	
	always @(posedge clk) begin
		if(reset)begin			///// reset
			for(i=0; i<32; i = i+1)begin
				GRF[i] <= 0;
			end
			DE_RD1 <= 0;
			DE_RD2 <= 0;
			DE_instruc <= 0;
			DE_WRA <= 0;
			DE_Ext <= 0;
			DE_PC <= 0;
			DE_BD <= 0;
		end
		else if(IntReq) begin	//////	STALL clear stream reg value == insert nop instruc
			DE_RD1 <= 0;
			DE_RD2 <= 0;
			DE_instruc <= 0;
			DE_WRA <= 0;
			DE_Ext <= 0;
			D_Exc <= `INT;
			DE_BD <= 0;
		end
		else if(stall)begin
			DE_RD1 <= 0;
			DE_RD2 <= 0;
			DE_instruc <= 0;
			DE_WRA <= 0;
			DE_Ext <= 0;
			D_Exc <= `INT;
			DE_BD <= D_BD;	//	allow pass when stall
			DE_PC <= D_PC;	//	allow pass when stall
		end
		else begin
			case(RegDst)
				2'b00:	DE_WRA <= 0;
				2'b01:	DE_WRA <= D_instruc[`rt];
				2'b10:	DE_WRA <= D_instruc[`rd];
				2'b11:	DE_WRA <= ra;
				default:	DE_WRA <= 5'bx;
			endcase
			
			case(ExtOp)
				1'b0:	DE_Ext <= {16'b0, D_instruc[`Imm16]};	//zero_ext
				1'b1:	DE_Ext <= {{16{D_instruc[15]}}, D_instruc[`Imm16]};//sign_ext
			endcase
			
			DE_RD1 <= RD1;
			DE_RD2 <= RD2;
			DE_instruc <= D_instruc;
			DE_PC <= D_PC;
			D_Exc <= D_Exc_wire;
			DE_BD <= D_BD;
		end
	end
	

endmodule
