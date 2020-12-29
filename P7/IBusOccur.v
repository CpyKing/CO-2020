`timescale 1ns / 1ps
`default_nettype none
`include "macro.v"
module IBusOccur(
	input wire [31:0] instruc,
	output wire [`NumOfI:0] IBus
    );
	// Bus Occur
		//	R
	assign IBus[`add]  = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b100000);
	assign IBus[`addu] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b100001);
	assign IBus[`sub]  = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b100010);
	assign IBus[`subu] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b100011);
	assign IBus[`And]  = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b100100);
	assign IBus[`Or]   = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b100101);
	assign IBus[`Xor]  = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b100110);
	assign IBus[`Nor]  = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b100111);
	assign IBus[`slt]  = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b101010);
	assign IBus[`sltu] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b101011);
	assign IBus[`sll]  = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b000000);
	assign IBus[`srl]  = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b000010);
	assign IBus[`sra]  = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b000011);
	assign IBus[`sllv] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b000100);
	assign IBus[`srlv] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b000110);	
 	assign IBus[`srav] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b000111);
	assign IBus[`jr]   = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b001000);
	assign IBus[`jalr] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b001001);
	
	assign IBus[`mult] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b011000);
	assign IBus[`multu]= (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b011001);
	assign IBus[`div]  = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b011010);
	assign IBus[`divu] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b011011);
	assign IBus[`mfhi] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b010000);
	assign IBus[`mflo] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b010010);
	assign IBus[`mthi] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b010001);
	assign IBus[`mtlo] = (instruc[`OpCode] == 6'b000000) && (instruc[`Func] == 6'b010011);
		//	I
	assign IBus[`addi] 	= (instruc[`OpCode] == 6'b001000);
	assign IBus[`addiu] = (instruc[`OpCode] == 6'b001001);
	assign IBus[`andi]  = (instruc[`OpCode] == 6'b001100);
	assign IBus[`ori] 	= (instruc[`OpCode] == 6'b001101);
	assign IBus[`xori]  = (instruc[`OpCode] == 6'b001110);
	assign IBus[`lui] 	= (instruc[`OpCode] == 6'b001111);
	assign IBus[`slti]  = (instruc[`OpCode] == 6'b001010);
	assign IBus[`sltiu] = (instruc[`OpCode] == 6'b001011);
	
	assign IBus[`lw]  	= (instruc[`OpCode] == 6'b100011);
	assign IBus[`lb]  	= (instruc[`OpCode] == 6'b100000);
	assign IBus[`lbu]  	= (instruc[`OpCode] == 6'b100100);
	assign IBus[`lh]  	= (instruc[`OpCode] == 6'b100001);
	assign IBus[`lhu]  	= (instruc[`OpCode] == 6'b100101);
	
	assign IBus[`sw]  = (instruc[`OpCode] == 6'b101011);
	assign IBus[`sb]  = (instruc[`OpCode] == 6'b101000);
	assign IBus[`sh]  = (instruc[`OpCode] == 6'b101001);
	
	assign IBus[`beq] = (instruc[`OpCode] == 6'b000100);
	assign IBus[`bgez]= (instruc[`OpCode] == 6'b000001 && instruc[`rt] == 5'b00001);	//	unique same with 'bltz'
	assign IBus[`bgtz]= (instruc[`OpCode] == 6'b000111);
	assign IBus[`blez]= (instruc[`OpCode] == 6'b000110);
	assign IBus[`bltz]= (instruc[`OpCode] == 6'b000001 && instruc[`rt] == 5'b00000);	//	unique same with 'bgez'
	assign IBus[`bne] = (instruc[`OpCode] == 6'b000101);
		// 	J
	assign IBus[`jal] = (instruc[`OpCode] == 6'b000011);
	assign IBus[`j]   = (instruc[`OpCode] == 6'b000010);
		//	INT & EXC
	assign IBus[`eret]= (instruc[`OpCode] == 6'b010000 && instruc[`Func] == 6'b011000);
	assign IBus[`mfc0]= (instruc[`OpCode] == 6'b010000 && instruc[`rs]   == 5'b00000);
	assign IBus[`mtc0]= (instruc[`OpCode] == 6'b010000 && instruc[`rs]   == 5'b00100);
		//	NOP
	assign IBus[`nop] = (instruc == 32'b0);
	
	//	Sort Instruction
	assign IBus[`I_R] = IBus[`add] || IBus[`addu] || IBus[`sub] || IBus[`subu] || IBus[`And] || IBus[`Or] || IBus[`Xor] || IBus[`Nor] || IBus[`slt] || IBus[`sltu];
	assign IBus[`Sft] = IBus[`sll] || IBus[`srl] || IBus[`sra];
	assign IBus[`VSft]= IBus[`sllv]|| IBus[`srlv]|| IBus[`srav];
	assign IBus[`I_I] = IBus[`addi]|| IBus[`addiu] || IBus[`andi] || IBus[`ori] || IBus[`xori] || IBus[`lui] || IBus[`slti] || IBus[`sltiu];
	assign IBus[`Load] = IBus[`lw] || IBus[`lb] || IBus[`lbu] || IBus[`lh] || IBus[`lhu];
	assign IBus[`Save] = IBus[`sw] || IBus[`sb] || IBus[`sh];
	assign IBus[`Branch] = IBus[`beq] || IBus[`bgez] || IBus[`bgtz] || IBus[`blez] || IBus[`bltz] || IBus[`bne];

endmodule
