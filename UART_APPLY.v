`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:31:33 10/31/2016 
// Design Name: 
// Module Name:    UART_APPLY 
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
module UART_APPLY(
	input[11:0] ADC_DATA,
	input clk,
	input rst_n,
	input[2:0] data_complete,
	output[7:0] rx_data,
	output uart_tx_int,
	input[7:0] rs232_data_rx,
	input[7:0] pixel_cnt,
	input clk_adc,
//	input otr,
	//for debug use
	output[7:0] pixel_buf_cnt_output,
	output[1:0] FIFO_r1_complete_output,
	output[1:0] FIFO_r2_complete_output,
	output[1:0] ADC_DATA_FIFO_JUDGE_output,
	output[8:0] pixel_rs232_cnt_output,
	output[11:0] min_adc_data_output
    );

//wire[15:0] rx_data_wire;
reg[15:0] rx_data_reg;
reg[7:0] rx_data_r;
reg[2:0] data_change_en;
reg hand_bit = 1'b0;
reg[24:0] cnt_hand = 25'b0;
reg[7:0] pixel_buf_cnt = 8'd0;;
reg[11:0] ADC_DATA_FIFO_r1[255:0];
reg[11:0] ADC_DATA_FIFO_r2[255:0];
reg ADC_DATA_FIFO_JUDGE = 0;
reg[1:0] FIFO_r1_complete,FIFO_r2_complete;
//reg[11:0] ADC_DATA_FIFO[255:0];
reg[8:0] pixel_rs232_cnt = 9'd0;
reg[11:0] min_adc_data=12'd4095;//ADC反相端输入，adcdata最小说明亮度最大
reg[11:0] min_adc_data_output_r;
//reg otr_r;
assign rx_data = rx_data_r;
assign uart_tx_int = hand_bit;//uart_tx_int == 1 说明可以开始发送数据
//assign rx_data_wire = ADC_DATA;
//for debug use
assign pixel_buf_cnt_output = pixel_buf_cnt;
assign FIFO_r1_complete_output = FIFO_r1_complete;
assign FIFO_r2_complete_output = FIFO_r2_complete;
assign ADC_DATA_FIFO_JUDGE_output = ADC_DATA_FIFO_JUDGE;
assign pixel_rs232_cnt_output = pixel_rs232_cnt;
assign min_adc_data_output = min_adc_data_output_r;
always @(posedge clk or negedge rst_n) begin

	if(!rst_n) begin
		//rx_data_reg <= 16'b0;
		data_change_en <= 2'b0;
		//cnt_hand <= 0;
		hand_bit <= 1'b0;
	end else begin 
//		otr_r <= otr;
	data_change_en <= data_complete;
	if(rs232_data_rx==16) begin hand_bit <= 1'b1;end
	else if((hand_bit == 1'b1) && (data_change_en == 3'd4)) begin hand_bit <= 1'b0;end
	else hand_bit <= hand_bit;
	end
end

always @(posedge clk_adc or negedge rst_n) begin
if(!rst_n) begin
FIFO_r1_complete <= 0;
FIFO_r2_complete <= 0;
end else begin 	
	if(pixel_cnt == 5) 	
	begin
	pixel_buf_cnt <= 0;
	min_adc_data <= 4095;
	end
	else 
	begin 
	pixel_buf_cnt <= pixel_buf_cnt + 1;
		if(min_adc_data > ADC_DATA)
		min_adc_data <= ADC_DATA;
	end
	if(pixel_buf_cnt == 255) 
	min_adc_data_output_r <= min_adc_data;//获得光斑最亮值，用作自适应控制
	
	if((ADC_DATA_FIFO_JUDGE == 0) && (!(FIFO_r1_complete==2))) 
		begin
			//ADC_DATA_FIFO_r1[pixel_buf_cnt] <= ADC_DATA;
			ADC_DATA_FIFO_r1[pixel_buf_cnt] <= (4095 - ADC_DATA);
//			if(min_adc_data > ADC_DATA) begin
//			min_adc_data <= ADC_DATA;
//			end
			if(pixel_buf_cnt == 255) begin
//			min_adc_data_output_r <= min_adc_data;
			//ADC_DATA_FIFO_r1[255] <= min_adc_data;
			//ADC_DATA_FIFO_r1[pixel_buf_cnt] <= ADC_DATA;
			FIFO_r1_complete <= FIFO_r1_complete + 1;
			FIFO_r2_complete <= 0;
			//ADC_DATA_FIFO_r2 <= ADC_DATA_FIFO_r;
			end
	end else if((ADC_DATA_FIFO_JUDGE == 1) && (!(FIFO_r2_complete==2))) 
		begin
			//ADC_DATA_FIFO_r2[pixel_buf_cnt] <= ADC_DATA;
			ADC_DATA_FIFO_r2[pixel_buf_cnt] <= (4095 - ADC_DATA);
//			if(min_adc_data > ADC_DATA) begin
//			min_adc_data <= ADC_DATA;
//			end
			if(pixel_buf_cnt == 255) begin
//			min_adc_data_output_r <= min_adc_data;
			//ADC_DATA_FIFO_r1[255] <= min_adc_data;
			//ADC_DATA_FIFO_r2[pixel_buf_cnt] <= ADC_DATA;
			FIFO_r2_complete <= FIFO_r2_complete + 1;
			FIFO_r1_complete <= 0;
			//ADC_DATA_FIFO_r2 <= ADC_DATA_FIFO_r;
			end
		end
	end
end

always  @(data_complete) begin

	/*if(data_complete) begin
	//if(data_change_en < 2'b11) begin
	rx_data_reg <= ADC_DATA;
	if(data_change_en == 0)
	data_change_en <= data_change_en + 1'b1;
	else if(data_change_en == 1)
	data_change_en <= 0;
	//end else begin
	//data_change_en <= 2'b0;
	//end
	end*/
	//if(!rst_n) ;
	//else begin
	//data_change_en <= data_complete;
	if(!rst_n) begin
//	rx_data_reg <= 16'b0;
//	pixel_rs232_cnt <= 0;
//	ADC_DATA_FIFO_JUDGE <= 1'd1;
	//data_change_en <= 2'b0;
	//cnt_hand <= 0;
	//hand_bit <= 1'b0;
	end else begin 
	//if(hand_bit==1'b1) begin
//	if(cnt_hand < 25'd31000000)
//	cnt_hand <= cnt_hand + 1;
//	else if(cnt_hand == 25'd31000000) cnt_hand <= cnt_hand;
//	else cnt_hand <= 0;
	//end
	
	//if(!rst_n) begin
//		rx_data_reg <= 16'b0;
//		data_change_en <= 2'b0;
	//end else begin

	//else if((cnt_hand == 7) || (cnt_hand == 8))begin
	//rx_data_r <= cnt_hand[7:0];
	case(data_change_en)
		3'b000: rx_data_r <= 8'hC8;
		3'b001: rx_data_r <= 8'hD2;
		3'b010: rx_data_r <= rx_data_reg[7:0];//pixel_rs232_cnt[7:0];
		3'b011: rx_data_r <= rx_data_reg[15:8];//ADC_DATA_FIFO_JUDGE;
		3'd4:  begin
		rx_data_r <= 8'bz;
	//endcase
		//2'b00: begin
		//rx_data_r <= 8'hC8; 
		//256 pixel data and 2 confirm data
//		if(pixel_rs232_cnt < 257) pixel_rs232_cnt <= pixel_rs232_cnt + 1;
//		else if (pixel_rs232_cnt == 257) pixel_rs232_cnt <= 0;
		//else pixel_rs232_cnt <= 0;
		
		/*if(pixel_rs232_cnt == 0) begin rx_data_reg <= 16'hC5E3;//start_confirm data
												 pixel_rs232_cnt <= pixel_rs232_cnt + 1;
										 end
		else if(pixel_rs232_cnt > 256) 
				begin pixel_rs232_cnt <= 0;
						rx_data_reg <= 16'hE3C5;//end confirm data
						if(ADC_DATA_FIFO_JUDGE == 0) ADC_DATA_FIFO_JUDGE <= 1;
						if(ADC_DATA_FIFO_JUDGE == 1) ADC_DATA_FIFO_JUDGE <= 0;
				end
		else if((pixel_rs232_cnt > 0) && (pixel_rs232_cnt < 257)) begin//pixel data
					pixel_rs232_cnt <= pixel_rs232_cnt + 1;
					case(ADC_DATA_FIFO_JUDGE)//choose register
						1'd0:	begin
								rx_data_reg <= ADC_DATA_FIFO_r1[pixel_rs232_cnt-1];
								//pixel_rs232_cnt <= pixel_rs232_cnt + 1;
								//if(pixel_rs232_cnt == 256) begin
								//rx_data_reg <= ADC_DATA_FIFO_r1[pixel_rs232_cnt];
								//ADC_DATA_FIFO_JUDGE <= 2'd2;
								//end
								end
						1'd1:	begin
								rx_data_reg <= ADC_DATA_FIFO_r2[pixel_rs232_cnt-1];
								//pixel_rs232_cnt <= pixel_rs232_cnt + 1;
								//if(pixel_rs232_cnt == 256) begin
								//rx_data_reg <= ADC_DATA_FIFO_r2[pixel_rs232_cnt];
								//ADC_DATA_FIFO_JUDGE <= 2'd1;
								//end
								end
						default: rx_data_reg <= rx_data_reg;
					endcase
				end
		 else rx_data_reg <= rx_data_reg;*/
		 end
	endcase
	
//	   if((cnt_hand <= 25'd200)/* && (data_change_en == 1)*/) begin
//		//rx_data_r <= cnt_hand[7:0];
//		end
////		else if((cnt_hand == 25'd2000) /*&& (data_change_en == 0)*/) begin
////		rx_data_r <= 8'd200;
////		//rx_data_reg <= ADC_DATA;
////		end
//		//else rx_data_r <= 8'd255;
//		else if(cnt_hand > 25'd200) begin
//		if(data_change_en == 1) begin
//		//rx_data_r <= 1;//rx_data_reg[7:0];
//		end
//		else if(data_change_en == 0) begin
//		//rx_data_r <= 2;//rx_data_reg[15:8];
//		//rx_data_reg <= ADC_DATA;
//		end
//		end
//		else rx_data_r <= 0;
	end
	//end
end		
//end
always  @(posedge hand_bit or negedge rst_n) begin
	if(!rst_n) begin
	rx_data_reg <= 16'b0;
	pixel_rs232_cnt <= 9'd0;
	ADC_DATA_FIFO_JUDGE <= 1'd0;
	end else begin 
	//if(data_change_en == 3'd4) begin
		if(pixel_rs232_cnt == 9'd0) begin rx_data_reg <= 16'hC5E3;//start_confirm data
												 pixel_rs232_cnt <= pixel_rs232_cnt + 1'b1;
										 end
		else if(pixel_rs232_cnt > 9'd256) 
				begin pixel_rs232_cnt <= 9'd0;
						rx_data_reg <= 16'hE3C5;//end confirm data
						if(ADC_DATA_FIFO_JUDGE == 0) ADC_DATA_FIFO_JUDGE <= 1;
						if(ADC_DATA_FIFO_JUDGE == 1) ADC_DATA_FIFO_JUDGE <= 0;
				end
		else if((pixel_rs232_cnt > 9'd0) && (pixel_rs232_cnt < 9'd257)) begin//pixel data
					pixel_rs232_cnt <= pixel_rs232_cnt + 1'b1;
					case(ADC_DATA_FIFO_JUDGE)//choose register
						1'd0:	begin
								rx_data_reg <= ADC_DATA_FIFO_r1[pixel_rs232_cnt-1];
								//pixel_rs232_cnt <= pixel_rs232_cnt + 1;
								//if(pixel_rs232_cnt == 256) begin
								//rx_data_reg <= ADC_DATA_FIFO_r1[pixel_rs232_cnt];
								//ADC_DATA_FIFO_JUDGE <= 2'd2;
								//end
								end
						1'd1:	begin
								rx_data_reg <= ADC_DATA_FIFO_r2[pixel_rs232_cnt-1];
								//pixel_rs232_cnt <= pixel_rs232_cnt + 1;
								//if(pixel_rs232_cnt == 256) begin
								//rx_data_reg <= ADC_DATA_FIFO_r2[pixel_rs232_cnt];
								//ADC_DATA_FIFO_JUDGE <= 2'd1;
								//end
								end
						default: rx_data_reg <= rx_data_reg;
					endcase
				end
		 else rx_data_reg <= rx_data_reg;
		 end
	end
	//end
endmodule
