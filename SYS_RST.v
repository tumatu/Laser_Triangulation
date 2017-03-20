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
module    SYS_RST
(
    input    clk,
    //input    rst_n,
    output    sys_rst_n,
	 output	  clk_adc
);
localparam	CLKADC_PARA = 10;	//10分频
localparam 	CLKADC_PARA_2 = 5;
//------------------------------------------
// Delay 100ms for steady state
reg[22:0] cnt;
reg[9:0]  cnt_adc = 0;
reg clk_adc_r;
always@(posedge clk) 
//or negedge rst_n)
begin
    //if(!rst_n)
      //  cnt <= 0;
   // else
     //   begin
			if(cnt < 23'd50_0000) //10ms
            cnt <= cnt+1'b1;
			else if(cnt == 23'd50_0000)
            cnt <= cnt;
			else cnt <= 0;
       // end
		 if(cnt_adc < CLKADC_PARA-1) cnt_adc <= cnt_adc + 1'b1;
		 else cnt_adc <= 10'd0;
end

//------------------------------------------
//rst_n synchronism
reg    rst_nr0 = 0;
reg    rst_nr1 = 0;
always@(posedge clk)
// or negedge rst_n)
begin
//    if(!rst_n)
//        begin
//        rst_nr0 <= 0;
//        rst_nr1 <= 0;
//        end
//    else 
	if(cnt == 23'd50_0000)
        begin
        rst_nr0 <= 1;
        rst_nr1 <= rst_nr0;
        end
    else
        begin
        rst_nr0 <= 0;
        rst_nr1 <= 0;
        end
	if(cnt_adc < CLKADC_PARA_2) clk_adc_r <= 1'b0;
	else
	clk_adc_r <= 1'b1;
end

assign    sys_rst_n = rst_nr1;
assign    clk_adc = clk_adc_r;
endmodule

