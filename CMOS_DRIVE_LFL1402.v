`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:08:21 10/31/2016 
// Design Name: 
// Module Name:    SYS_RST 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
/**************************************
*  功能：同步复位产生模块
*  输入参数：
*         1.  clk： 50M 时钟输入
*         2.  全局复位信号
*  输出参数：
*         sys_rst_n:系统全局同步复位信号
***************************************/
module CMOS_DRIVE_LFL1402
(
    input    clk,
    input    rst_n,
    output   clk_lfl1402,
	 output	 clk_st_lfl1402,
	 output   DIS_lfl1402,
	 output	 [7:0]pixel_cnt
);

localparam	CLKLFL1402_PARA = 50;	//50分频
localparam 	CLKLFL1402_PARA_2 = 25;
/*
localparam	CLKLFL1402_PARA = 1000;	//1000分频
localparam 	CLKLFL1402_PARA_2 = 500;*/
localparam	ST_LFL1402_PARA = 256;	//256分频
localparam 	ST_LFL1402_PARA_2 = 1;
//------------------------------------------
// Delay 100ms for steady state
reg[9:0] cnt;
reg[9:0] cnt_st;
reg clk_lfl1402_r;
reg clk_st_lfl1402_r;
reg DIS_lfl1402_r = 0;
reg [7:0] pixel_cnt_r;
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
         cnt <= 0;
    else begin
			if(cnt < (CLKLFL1402_PARA - 1)) 
            cnt <= cnt+1;
			else if(cnt == (CLKLFL1402_PARA - 1))
				cnt <= 0;
			if(cnt < CLKLFL1402_PARA_2) 
				clk_lfl1402_r <= 1'b0;
			else clk_lfl1402_r <= 1'b1;
			end
end

//------------------------------------------

always@(negedge clk_lfl1402 or negedge rst_n)  //clk_lfl1402下降沿
begin
	 if(!rst_n)
        cnt_st <= 0;
	 else begin
			if(cnt_st < (ST_LFL1402_PARA - 1))
            cnt_st <= cnt_st+1'b1;
			else if(cnt_st == (ST_LFL1402_PARA - 1)) 
				cnt_st <= 0;
			
			if(cnt_st < ST_LFL1402_PARA_2) 
				clk_st_lfl1402_r <= 1'b1;
			else clk_st_lfl1402_r <= 1'b0;
			end
end

always@(posedge clk_lfl1402 or negedge rst_n) begin
if(!rst_n)
         pixel_cnt_r <= 0;
else begin if(clk_st_lfl1402_r==0) 
			pixel_cnt_r <= pixel_cnt_r + 1;
			else pixel_cnt_r <= 0;
			end
end
//
//always@(posedge clk or negedge rst_n) 
//begin
////	if(!rst_n)
////        clk_lfl1402_r <= 0;
////		  clk_st_lfl1402_r <= 0;
////	else 	begin
//			if(cnt < CLKLFL1402_PARA_2) 
//				clk_lfl1402_r <= 1'b0;
//			else begin clk_lfl1402_r <= 1'b1;
//			end
//			
//			if(cnt_st < ST_LFL1402_PARA_2) 
//				clk_st_lfl1402_r <= 1'b0;
//			else begin clk_st_lfl1402_r <= 1'b1;
//			end
////			end
//end

assign    clk_lfl1402 = clk_lfl1402_r;
assign    clk_st_lfl1402 = clk_st_lfl1402_r;
assign    DIS_lfl1402 = DIS_lfl1402_r;
assign    pixel_cnt = pixel_cnt_r;
endmodule

