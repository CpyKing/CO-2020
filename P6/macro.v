`timescale 1ns / 1ps
`define OpCode 	31:26
`define rs		25:21
`define rt		20:16
`define rd		15:11
`define shamt	10: 6
`define Func	 5: 0
`define Imm16	15: 0
`define Imm26	25: 0

`define ADD	4'b0000
`define SUB	4'b0001
`define OR	4'b0010
`define LH	4'b0011
`define XOR	4'b0100
`define NOR	4'b0101
`define AND	4'b0110
`define STO 4'b0111
`define STOU 4'b1000
`define SLL 4'b1001
`define SRL	4'b1010
`define SRA	4'b1011

`define NumOfI	57

`define addu	0
`define subu	1
`define jr		2
`define lui		3
`define ori		4
`define beq		5
`define lw		6
`define sw		7
`define j		8
`define jal		9
`define lb		10
`define sb		11
`define nop		12
`define jalr	13
`define addi	14
`define lbu		15
`define lh		16
`define lhu		17
`define sh		18
`define bne		19
`define blez	20
`define bgtz	21
`define bltz	22
`define bgez	23
`define add		24
`define sub		25
`define And		26
`define Or		27
`define Xor		28
`define Nor		29
`define addiu	30
`define andi	31
`define xori	32
`define slt		33
`define sltu	34
`define slti	35
`define sltiu	36
`define sll		37
`define srl		38
`define sra		39
`define sllv	40
`define srlv	41
`define srav	42
`define mult	43
`define multu	44
`define div		45
`define divu	46
`define mfhi	47
`define mflo	48
`define mthi	49
`define mtlo	50

`define I_R		51
`define I_I		52
`define Sft		53
`define VSft	54
`define Load	55
`define Save	56
`define Branch	57
