`timescale 1ns / 1ps
`default_nettype none
`include "macro.v"
module mips(
	input wire clk,
	input wire reset,
	
	input wire interrupt,
	output wire [31:0] addr
    );
	
	//	Declaration
	wire [31:0] EM_AluRe, PrRD, dev_WD, dev1_RD, dev0_RD, M_WD;
	wire [31:0] dev_Addr;
	wire pick0, pick1, writeTimer, IRQ_0, IRQ_1;
	
	CPU_Core core(.clk(clk), .reset(reset),
				  .interrupt(interrupt),
				  .EM_AluRe(EM_AluRe), .M_WD(M_WD), .writeTimer(writeTimer),
				  .PrRD(PrRD), .IRQ_1(IRQ_1), .IRQ_0(IRQ_0), .addr(addr));
	
	//	Bridge
	Bridge bridge(.PrAddr(EM_AluRe), .PrWD(M_WD), .dev0_RD(dev0_RD), .dev1_RD(dev1_RD), .writeTimer(writeTimer),
				  .PrRD(PrRD), .dev_Addr(dev_Addr), .dev_WD(dev_WD), .pick0(pick0), .pick1(pick1));	
	//	Timer
	 TC timer0(.clk(clk), .reset(reset),
			   .Addr(dev_Addr),
			   .WE(pick0),
			   .Din(dev_WD),
			   .Dout(dev0_RD),
			   .IRQ(IRQ_0));
	 TC timer1(.clk(clk), .reset(reset),
			   .Addr(dev_Addr),
			   .WE(pick1),
			   .Din(dev_WD),
			   .Dout(dev1_RD),
			   .IRQ(IRQ_1));
endmodule
