`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:35:39 10/31/2016 
// Design Name: 
// Module Name:    UART_CLOCK 
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
//////////////////////////////////////////////////////////////////////////////////
module UART_CLOCK(
   clk,rst_n,
	bps_start,clk_bps
			);

input clk;	// 50MHz主时钟
input rst_n;	//低电平复位信号
input bps_start;	//接收到数据后，波特率时钟启动信号置位
output clk_bps;	// clk_bps的高电平为接收或者发送数据位的中间采样点 

/*
parameter 		bps9600 	= 5208,	//波特率为9600bps
			 	bps19200 	= 2604,	//波特率为19200bps
				bps38400 	= 1302,	//波特率为38400bps
				bps57600 	= 868,	//波特率为57600bps
				bps115200	= 434;	//波特率为115200bps
				bps115200	= 41667;	//波特率为1200bps

parameter 		bps9600_2 	= 2604,
				bps19200_2	= 1302,
				bps38400_2	= 651,
				bps57600_2	= 434,
				bps115200_2 = 217;  
				bps115200_2 = 20834;
*/

	//以下波特率分频计数值可参照上面的参数进行更改
`define		BPS_PARA		434	//波特率为115200bps
`define 	BPS_PARA_2		217	//波特率为115200时的分频计数值的一半，用于数据采样
/*
`define		BPS_PARA		41667	//波特率为1200bps
`define 	BPS_PARA_2		20834	//波特率为1200时的分频计数值的一半，用于数据采样
*/

reg[12:0] cnt;			//分频计数
reg clk_bps_r;			//波特率时钟寄存器

//----------------------------------------------------------
//reg[2:0] uart_ctrl;	// uart波特率选择寄存器
//----------------------------------------------------------

always @ (posedge clk or negedge rst_n)
	if(!rst_n) cnt <= 13'd0;
	else if((cnt == (`BPS_PARA-1)) || !bps_start) cnt <= 13'd0;	//波特率计数清零
	else cnt <= cnt+1'b1;			//波特率时钟计数启动

always @ (posedge clk or negedge rst_n)
	if(!rst_n) clk_bps_r <= 1'b0;
	else if(cnt == `BPS_PARA_2) clk_bps_r <= 1'b1;	// clk_bps_r高电平为接收数据位的中间采样点,同时也作为发送数据的数据改变点
	else clk_bps_r <= 1'b0;

assign clk_bps = clk_bps_r;

endmodule

