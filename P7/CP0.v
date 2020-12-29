`timescale 1ns / 1ps
`default_nettype none
module CP0(
	input wire clk,
	input wire reset,
	
	input wire [4:0] A1,
	input wire [4:0] A2,
	input wire [31:0] DIn,
	input wire [31:0] PC,
	input wire [6:2] ExcCode,
	input wire [15:10] HWInt,
	input wire WE,
	input wire EXLSet,
	input wire EXLClr,
	input wire BD,
	
	output wire IntReq,
	output wire [31:0] EPC,
	output wire [31:0] DOut	
    );
	//	Declaration
	wire interrupt, exception;
	//	Design SR
	reg [15:10] SR_im;
	reg exl, ie;
	wire [31:0] reg_SR = {16'b0, SR_im, 8'b0, exl, ie};
	
	//	Design Cause
	reg reg_BD;
	reg [15:10] reg_HWInt;
	reg [6:2] reg_ExcCode;
	wire [31:0] reg_Cause = {reg_BD, 15'b0, reg_HWInt, 3'b0, reg_ExcCode, 2'b0};
	
	//	Design EPC
	reg [31:0] reg_EPC;
	assign EPC = reg_EPC;
	//	Design PRID
	reg	[31:0] PRID;
	
	//
	assign interrupt = (|(HWInt & SR_im)) & ie & !exl;
	assign exception = (ExcCode > 5'd0);
	assign IntReq = interrupt || exception;
	
	assign DOut = (A1 == 12) ? reg_SR :
				  (A1 == 13) ? reg_Cause :
				  (A1 == 14) ? reg_EPC :
				  (A1 == 15) ? PRID : 0;
	
	always @(posedge clk)begin
		if(reset)begin
			SR_im <= 0;
			exl <= 0;
			ie <= 0;
			reg_BD <= 0;
			reg_HWInt <= 0;
			reg_ExcCode <= 0;
			reg_EPC <= 0;
			PRID <= 0;
		end
		else begin
			if(WE)begin
				case(A2)
					12:	{SR_im, exl, ie} <= {DIn[15:10], DIn[1:0]};
					14:	reg_EPC <= {DIn[31:2], 2'b00};
					default:	PRID <= 32'h19373385;
				endcase
			end
			else begin
				if(EXLSet)begin
					exl <= 1'b1;
				end
				if(EXLClr)begin
					exl <= 1'b0;
				end
				if(exl == 0)begin
					reg_BD <= BD;
					reg_HWInt <= HWInt;
					reg_ExcCode <= ExcCode;
					reg_EPC	<= (BD) ? ({PC[31:2], 2'b00} - 4) : ({PC[31:2], 2'b00});
				end
			end
		end
	end
	
	//	initial
	initial begin
		SR_im <= 0;
		exl <= 0;
		ie <= 0;
		reg_BD <= 0;
		reg_HWInt <= 0;
		reg_ExcCode <= 0;
		reg_EPC <= 0;
		PRID <= 0;
	end
	//
	
	/*
	//	Declaration
	reg [31:0] SR, Cause, PRId;
	reg exl;
	wire [15:10] im;
	wire ie;
	wire cut;
	wire interrupt, exception;
	//	Initial
	initial begin
		SR <= 0;
		Cause <= 0;
		EPC <= 0;
		PRId <= 32'h12345678;
		exl <= 0;
	end
	//	IntReq signal Generate
	always @(posedge clk)begin
		if(reset)begin
			SR <= 0;
			Cause <= 0;
			EPC <= 0;
			PRId <= 32'h12345678;
			exl <= 0;
		end
		else begin
			//	MTCO
			if(WE)begin
				if(A2 == 12)begin		//	SR
					SR <= DIn;
					exl <= DIn[1];
				end
				else if(A2 == 14)begin	//	EPC
					EPC <= DIn;
				end
				else if(A2 == 15)begin	//	PRId
					PRId <= DIn;
				end
			end
			//	exl
			if(EXLSet)		exl <= 1;
			else if(EXLClr)	exl <= 0;
			//	EPC save
			if(IntReq) EPC <= PC;
			//	Cause sace
			if(IntReq)begin
				if(cut)	Cause <= {BD, 15'b0, HWInt[15:10], 3'b0, 5'b0, 2'b0};
				else	Cause <= {BD, 15'b0, HWInt[15:10], 3'b0, ExcCode[6:2], 2'b0};
			end
			if(exl == 0) Cause[15:10] <= HWInt[15:10];
		end
	end
	
	//	IntReq signal Generate & cut
	assign cut = (ie == 1 && exl == 0) ? (|(HWInt[15:10] & im[15:10])) : 0;
	
	assign interrupt = (|(HWInt & im)) & ie & !exl;
	assign exception = (ExcCode > 5'b0);
	
	assign IntReq =  interrupt || exception;
	//	DOut
	assign DOut = (A1 == 12) ? SR	 :
				  (A1 == 13) ? Cause :
				  (A1 == 14) ? EPC	 :
				  (A1 == 15) ? PRId	 : 0;
	//	SR
	assign im = SR[15:10];
	assign ie = SR[0];
	*/

endmodule
