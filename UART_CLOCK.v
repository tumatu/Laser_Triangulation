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

input clk;	// 50MHz��ʱ��
input rst_n;	//�͵�ƽ��λ�ź�
input bps_start;	//���յ����ݺ󣬲�����ʱ�������ź���λ
output clk_bps;	// clk_bps�ĸߵ�ƽΪ���ջ��߷�������λ���м������ 

/*
parameter 		bps9600 	= 5208,	//������Ϊ9600bps
			 	bps19200 	= 2604,	//������Ϊ19200bps
				bps38400 	= 1302,	//������Ϊ38400bps
				bps57600 	= 868,	//������Ϊ57600bps
				bps115200	= 434;	//������Ϊ115200bps
				bps115200	= 41667;	//������Ϊ1200bps

parameter 		bps9600_2 	= 2604,
				bps19200_2	= 1302,
				bps38400_2	= 651,
				bps57600_2	= 434,
				bps115200_2 = 217;  
				bps115200_2 = 20834;
*/

	//���²����ʷ�Ƶ����ֵ�ɲ�������Ĳ������и���
`define		BPS_PARA		434	//������Ϊ115200bps
`define 	BPS_PARA_2		217	//������Ϊ115200ʱ�ķ�Ƶ����ֵ��һ�룬�������ݲ���
/*
`define		BPS_PARA		41667	//������Ϊ1200bps
`define 	BPS_PARA_2		20834	//������Ϊ1200ʱ�ķ�Ƶ����ֵ��һ�룬�������ݲ���
*/

reg[12:0] cnt;			//��Ƶ����
reg clk_bps_r;			//������ʱ�ӼĴ���

//----------------------------------------------------------
//reg[2:0] uart_ctrl;	// uart������ѡ��Ĵ���
//----------------------------------------------------------

always @ (posedge clk or negedge rst_n)
	if(!rst_n) cnt <= 13'd0;
	else if((cnt == (`BPS_PARA-1)) || !bps_start) cnt <= 13'd0;	//�����ʼ�������
	else cnt <= cnt+1'b1;			//������ʱ�Ӽ�������

always @ (posedge clk or negedge rst_n)
	if(!rst_n) clk_bps_r <= 1'b0;
	else if(cnt == `BPS_PARA_2) clk_bps_r <= 1'b1;	// clk_bps_r�ߵ�ƽΪ��������λ���м������,ͬʱҲ��Ϊ�������ݵ����ݸı��
	else clk_bps_r <= 1'b0;

assign clk_bps = clk_bps_r;

endmodule

