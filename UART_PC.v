`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:48:13 10/26/2016 
// Design Name: 
// Module Name:    UART_PC 
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
module UART_PC(
	clk,rst_n,
	rx_data,rx_int,rs232_tx,
	clk_bps,bps_start,data_tx_done
			);

input clk;			// 50MHz主时钟
input rst_n;		//低电平复位信号
input clk_bps;		// clk_bps_r高电平为接收数据位的中间采样点,同时也作为发送数据的数据改变点
input[7:0] rx_data;	//接收数据寄存器
input rx_int;		//发送数据准备完毕
output rs232_tx;	// RS232发送数据信号
output bps_start;	//接收或者要发送数据，波特率时钟启动信号置位
output[2:0] data_tx_done;//输出一个字节发送完成信号，用于两字节数据的切换

//---------------------------------------------------------
reg[7:0] tx_data;	//待发送数据的寄存器
//---------------------------------------------------------
reg bps_start_r;
reg tx_en;	//发送数据使能信号，高有效
reg[3:0] num;
reg[2:0] data_tx_done_r = 3'b0;

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			bps_start_r <= 1'bz;
			tx_en <= 1'b0;
			tx_data <= 8'd0;
		end
	else if(rx_int) begin	//接收数据完毕，准备把接收到的数据发回去
			bps_start_r <= 1'b1;
			tx_data <= rx_data;	//把接收到的数据存入发送数据寄存器
			tx_en <= 1'b1;		//进入发送数据状态中
		end
//	else if(!(rx_int)) begin
//			data_tx_done_r <= 3'b0;
//			end
	else if(num==4'd10) begin	//数据发送完成，复位
			bps_start_r <= 1'b0;
			tx_en <= 1'b0;
		end
end

assign bps_start = bps_start_r;

//---------------------------------------------------------
reg rs232_tx_r;

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			num <= 4'd0;//重新发送数据（10位串行数据）
			rs232_tx_r <= 1'b1;//串口默认高电平为空闲
			data_tx_done_r <= 3'b0;
		end
	else if(!(rx_int)) begin
			data_tx_done_r <= 3'b0;
			end
	else if(tx_en) begin
			if(clk_bps)	begin
					num <= num+1'b1;
					case (num)
						4'd0: begin 
								rs232_tx_r <= 1'b0; 	//发送起始位
								//data_tx_done_r <= 1'b0;
								end
						4'd1: rs232_tx_r <= tx_data[0];	//发送bit0
						4'd2: rs232_tx_r <= tx_data[1];	//发送bit1
						4'd3: rs232_tx_r <= tx_data[2];	//发送bit2
						4'd4: rs232_tx_r <= tx_data[3];	//发送bit3
						4'd5: rs232_tx_r <= tx_data[4];	//发送bit4
						4'd6: rs232_tx_r <= tx_data[5];	//发送bit5
						4'd7: rs232_tx_r <= tx_data[6];	//发送bit6
						4'd8: rs232_tx_r <= tx_data[7];	//发送bit7
						4'd9: begin
								rs232_tx_r <= 1'b1;	//发送结束位
								if(data_tx_done_r<3'd4)	data_tx_done_r <= data_tx_done_r + 2'b1;
								else data_tx_done_r <= 0;
								end
					 	default: begin
									rs232_tx_r <= 1'b1;
									//data_tx_done_r <= 1'b0;
									end
					endcase
				end
			else if(num==4'd15) num <= 4'd0;	//复位
		end
end

assign rs232_tx = rs232_tx_r;
assign data_tx_done = data_tx_done_r;
endmodule

