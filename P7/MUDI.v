`timescale 1ns / 1ps
`default_nettype none
module MUDI(
	input wire clk,
	input wire reset,
	input wire [31:0] instruc,
	input wire [31:0] MD_A,
	input wire [31:0] MD_B,
	input wire interrupt,
	
	output wire start,
	output reg [4:0] busyCnt,
	
	output wire [31:0] HLRe
    );
	//	Declaration
	wire isMU, isDI, MUDI, isSigned;
	wire WriteHL, WriteHi, ReadHi;
	wire busy;
	reg [31:0] hi;
	reg [31:0] lo;
	reg reg_isMU, reg_isDI, reg_isSigned;
	reg [31:0] A, B;
	reg [63:0] reg_Result;
	wire [63:0] Result;
	//	Controller
	Controller Con_MUDI(.instruc(instruc),
						.isMU(isMU), .isDI(isDI), .isSigned(isSigned), .MUDI(MUDI),
						.WriteHL(WriteHL), .WriteHi(WriteHi), .ReadHi(ReadHi));
	//
	assign Result = reg_Result;
	assign HLRe = (ReadHi == 1) ? hi : lo;
	always@(*)begin
		if(reg_isMU)begin
			if(reg_isSigned)
				reg_Result = $signed(A) * $signed(B);
			else
				reg_Result = A * B;
		end
		else if(reg_isDI)begin
			if(reg_isSigned)
				reg_Result = {$signed(A) % $signed(B), $signed(A) / $signed(B)};
			else
				reg_Result = {A % B, A / B};
		end
	end
	assign start = MUDI && (busy == 0);
	assign busy = (busyCnt != 0);
	always @(posedge clk)begin
		if(reset) begin
			reg_isMU <= 0;
			reg_isDI <= 0;
			reg_isSigned <= 0;
			busyCnt <= 0;
			hi <= 0;
			lo <= 0;
			A <= 0;
			B <= 0;
			reg_Result <= 0;
		end
		else begin
			if(WriteHL == 1 && interrupt == 0) begin
				if(WriteHi)	hi <= MD_A;
				else lo <= MD_A;
			end
			else begin
				if(MUDI && (busyCnt == 0))begin
					reg_isMU <= isMU;
					reg_isDI <= isDI;
					reg_isSigned <= isSigned;
					A <= MD_A;
					B <= MD_B;
					busyCnt <= (interrupt == 1) ? 0 : (isMU) ? 5 : (isDI) ? 10 : 0;
				end
				if(busyCnt > 0)
					busyCnt <= busyCnt - 1;
				if(busyCnt == 1) begin
					hi <= (B == 0) ? hi : Result[63:32];
					lo <= (B == 0) ? lo : Result[31:0];
				end
			end
		end
	end
	//	initial
	initial begin
		reg_isMU <= 0;
		reg_isDI <= 0;
		reg_isSigned <= 0;
		busyCnt <= 0;
		hi <= 0;
		lo <= 0;
		A <= 0;
		B <= 0;
		reg_Result <= 0;
	end
	


endmodule
