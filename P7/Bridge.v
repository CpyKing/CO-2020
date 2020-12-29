`timescale 1ns / 1ps
`default_nettype none
module Bridge(
	input wire [31:0] PrAddr,
	input wire [31:0] PrWD,
	input wire [31:0] dev0_RD,
	input wire [31:0] dev1_RD,
	input wire writeTimer,
	
	output wire [31:0] PrRD,
	output wire [31:0] dev_Addr,
	output wire [31:0] dev_WD,
	output wire pick0,
	output wire pick1	
    );
	
	assign dev_Addr = PrAddr;
	assign dev_WD = PrWD;
	assign PrRD = (PrAddr[4] == 0) ? dev0_RD : dev1_RD;
	assign pick0 = (PrAddr[4] == 0 && writeTimer == 1) ? 1 : 0;
	assign pick1 = (PrAddr[4] == 1 && writeTimer == 1) ? 1 : 0;

endmodule
