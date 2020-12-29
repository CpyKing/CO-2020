`timescale 1ns / 1ps
`default_nettype none
module NPC(
	input wire branchJump,
	input wire immJump,
	input wire regJump,
	input wire [31:0] regValue,
	input wire [15:0] imm16,
	input wire [25:0] imm26,
	input wire [31:0] PC,
	
	input wire [31:0] EPC,
	input wire eJump,
	input wire IntReq,
	
	output wire [31:0] NPC
    );
	//	Declaration
	reg [31:0] reg_NPC;
	wire [31:0] APC = PC + 4;
	wire [31:0] BPC = PC + ({{16{imm16[15]}}, imm16} << 2);//PC + 4 + sign_ext(imm16)
	wire [31:0] IPC = {APC[31:28], imm26, 2'b00};		//(PC + 4) high 4 bits || imm16 || 00
	wire [31:0] RPC = regValue;
	//
	always @(*) begin
		if(IntReq)					
			reg_NPC = 32'h00004180;
		else if(eJump)
			reg_NPC = EPC;
		else begin
			if(branchJump == 1)
				reg_NPC = BPC;
			else if(immJump == 1)
				reg_NPC = IPC;
			else if(regJump == 1)
				reg_NPC = RPC;
			else
				reg_NPC = APC;
		end
		
		
	end
	assign NPC = reg_NPC;
	//assign NPC = (branchJump == 1)  ? BPC :
	//			 (immJump == 1)	   ? IPC :
	//			 (regJump == 1)	   ? RPC : APC;
endmodule
