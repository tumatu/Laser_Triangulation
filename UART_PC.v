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

input clk;			// 50MHz��ʱ��
input rst_n;		//�͵�ƽ��λ�ź�
input clk_bps;		// clk_bps_r�ߵ�ƽΪ��������λ���м������,ͬʱҲ��Ϊ�������ݵ����ݸı��
input[7:0] rx_data;	//�������ݼĴ���
input rx_int;		//��������׼�����
output rs232_tx;	// RS232���������ź�
output bps_start;	//���ջ���Ҫ�������ݣ�������ʱ�������ź���λ
output[2:0] data_tx_done;//���һ���ֽڷ�������źţ��������ֽ����ݵ��л�

//---------------------------------------------------------
reg[7:0] tx_data;	//���������ݵļĴ���
//---------------------------------------------------------
reg bps_start_r;
reg tx_en;	//��������ʹ���źţ�����Ч
reg[3:0] num;
reg[2:0] data_tx_done_r = 3'b0;

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			bps_start_r <= 1'bz;
			tx_en <= 1'b0;
			tx_data <= 8'd0;
		end
	else if(rx_int) begin	//����������ϣ�׼���ѽ��յ������ݷ���ȥ
			bps_start_r <= 1'b1;
			tx_data <= rx_data;	//�ѽ��յ������ݴ��뷢�����ݼĴ���
			tx_en <= 1'b1;		//���뷢������״̬��
		end
//	else if(!(rx_int)) begin
//			data_tx_done_r <= 3'b0;
//			end
	else if(num==4'd10) begin	//���ݷ�����ɣ���λ
			bps_start_r <= 1'b0;
			tx_en <= 1'b0;
		end
end

assign bps_start = bps_start_r;

//---------------------------------------------------------
reg rs232_tx_r;

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			num <= 4'd0;//���·������ݣ�10λ�������ݣ�
			rs232_tx_r <= 1'b1;//����Ĭ�ϸߵ�ƽΪ����
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
								rs232_tx_r <= 1'b0; 	//������ʼλ
								//data_tx_done_r <= 1'b0;
								end
						4'd1: rs232_tx_r <= tx_data[0];	//����bit0
						4'd2: rs232_tx_r <= tx_data[1];	//����bit1
						4'd3: rs232_tx_r <= tx_data[2];	//����bit2
						4'd4: rs232_tx_r <= tx_data[3];	//����bit3
						4'd5: rs232_tx_r <= tx_data[4];	//����bit4
						4'd6: rs232_tx_r <= tx_data[5];	//����bit5
						4'd7: rs232_tx_r <= tx_data[6];	//����bit6
						4'd8: rs232_tx_r <= tx_data[7];	//����bit7
						4'd9: begin
								rs232_tx_r <= 1'b1;	//���ͽ���λ
								if(data_tx_done_r<3'd4)	data_tx_done_r <= data_tx_done_r + 2'b1;
								else data_tx_done_r <= 0;
								end
					 	default: begin
									rs232_tx_r <= 1'b1;
									//data_tx_done_r <= 1'b0;
									end
					endcase
				end
			else if(num==4'd15) num <= 4'd0;	//��λ
		end
end

assign rs232_tx = rs232_tx_r;
assign data_tx_done = data_tx_done_r;
endmodule

