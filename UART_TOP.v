`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:40:42 10/31/2016 
// Design Name: 
// Module Name:    UART_TOP 
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
//FPGA UART TX TO PC
//include "UART_CLOCK.v"
//include "UART_PC.v"
module UART_TOP(				
	clk,ADC_DATA,
	CLK_ADC,OE_PIN,OTR_PIN,
	//rst_n,
	//rx_data,
	rs232_tx,rs232_rx,
	SDO,SDI,SCLK,CSB,CLRB,LDACB,
	PCB_GND,PCB_GND2,PCB_GND3,PCB_GND4,PCB_GND5,PCB_3V3,
	clk_lfl1402,clk_st_lfl1402,DIS_lfl1402,
	pixel_buf_cnt_output,FIFO_r1_complete_output,FIFO_r2_complete_output,
   ADC_DATA_FIFO_JUDGE_output,pixel_rs232_cnt_output
				);

input clk;			// 50MHz主时钟
input[11:0] ADC_DATA;
//wire[11:0] ADC_DATA_in = ADC_DATA;
//output rst_n;		//低电平复位信号

//input[7:0] rx_data;		// RS232接收数据信号
input  rs232_rx;
input SDO;
output rs232_tx;	//	RS232发送数据信号
output CLK_ADC,OE_PIN;
input OTR_PIN;
output SDI,SCLK,CSB,CLRB,LDACB;
output PCB_GND,PCB_GND2,PCB_GND3,PCB_GND4,PCB_GND5,PCB_3V3;
output clk_lfl1402,clk_st_lfl1402,DIS_lfl1402;
output[7:0] pixel_buf_cnt_output;
output[1:0] FIFO_r1_complete_output;
output[1:0] FIFO_r2_complete_output;
output[1:0] ADC_DATA_FIFO_JUDGE_output;
output[8:0] pixel_rs232_cnt_output;
//reg rst_n_r;
//localparam[7:0] rx_data = 8'b00111101;
localparam rx_int_r = 1'b1;
//localparam DAC_DATA = 24'b000010001111111100010000;
//localparam DAC_DATA = 24'b000010001100001100010000;
reg[23:0] DAC_DATA,DAC_DATA_r;
//reg DAC_DATA_change;
reg[7:0] DAC_DATA_1 = 8'b00100000;
reg[15:0] DAC_DATA_2 = 16'd20000;
reg[3:0] count_laser = 4'b0;
reg[11:0] ADC_DATA_REV = 12'd0;
reg[11:0] min_adc_data_output_REV = 12'd0;
//reg[11:0] min_adc_data_output_top;

localparam START_EN = 1'b1;
//reg START_EN;
localparam PCB_GND_r = 1'b0;
localparam PCB_GND2_r = 1'b0;
localparam PCB_GND3_r = 1'b0;
localparam PCB_GND4_r = 1'b0;
localparam PCB_GND5_r = 1'b0;
localparam PCB_3V3_r = 1'b1;
localparam ADC_DATA_temp = 12'b001111110111;
//reg[23:0] DAC_DATA;
wire[7:0] rx_data_r,rs232_data_rx;
wire bps_start_tx, clk_bps_tx;
wire[2:0] data_tx_done; 
wire uart_tx_int;
wire[7:0] pixel_cnt;
wire clk_lfl1402;
//wire CLK_ADC;
(* KEEP="TRUE"*) wire [11:0] min_adc_data_output;
/*always @ (posedge clk) begin
min_adc_data_output_top <= min_adc_data_output;
end*/
/*reg otr_pin_reg;
always @ (posedge clk) begin
otr_pin_reg <= OTR_PIN;
end*/
/*reg[11:0] ADC_format_change;//黑金模块
always @ (posedge clk) begin
if(ADC_DATA > 12'h7FF) ADC_format_change <= (ADC_DATA - 12'h800); 
if(ADC_DATA < 12'h800) ADC_format_change <= (ADC_DATA + 12'h800);
end*/
/*//(* KEEP="TRUE"*) wire[11:0] ADC_format_change_test;//黑金模块
(* KEEP="TRUE"*) wire ADC_format_change_test;//黑金模块
//assign ADC_format_change_test = (ADC_DATA ^ 12'h800);
assign ADC_format_change_test = ~ADC_DATA[11];*/
//assign CLK_ADC = clk_lfl1402;
assign PCB_GND = PCB_GND_r;
assign PCB_GND2 = PCB_GND2_r;
assign PCB_GND3 = PCB_GND3_r;
assign PCB_GND4 = PCB_GND4_r;
assign PCB_GND5 = PCB_GND5_r;
assign PCB_3V3 = PCB_3V3_r;
assign OE_PIN = 0;
assign CLK_ADC = clk_lfl1402;
//assign min_adc_data_output_top = min_adc_data_output;
//always @ (posedge clk) begin
//assign rx_data = rx_data_r;
//UART CODE
SYS_RST			SYS_RST(
						.clk(clk),
						.sys_rst_n(rst_n)
						//.clk_adc(CLK_ADC)
						);
CMOS_DRIVE_LFL1402	CMOS_DRIVE_LFL1402(
						.clk(clk),
						.rst_n(rst_n),
						.clk_lfl1402(clk_lfl1402),
						.clk_st_lfl1402(clk_st_lfl1402),
						.DIS_lfl1402(DIS_lfl1402),
						.pixel_cnt(pixel_cnt)
						);
my_uart_rx		UART_RX(
						.clk(clk),
						.rst_n(rst_n),
						.rs232_rx(rs232_rx),//串口输入
						.rx_data(rs232_data_rx),//串口接收到的8位数据
						//.rx_int(rx_int)，//接收数据中断信号
						.clk_bps(clk_bps_rx),
						.bps_start(bps_start_rx)
					);						
UART_CLOCK		UART_CLOCK_RX(	
							.clk(clk),	//波特率选择模块
							.rst_n(rst_n),
							.bps_start(bps_start_rx),
							.clk_bps(clk_bps_rx)
						);
UART_CLOCK		UART_CLOCK_TX(	
							.clk(clk),	//波特率选择模块
							.rst_n(rst_n),
							.bps_start(bps_start_tx),
							.clk_bps(clk_bps_tx)
						);
						
UART_PC			UART_PC_TX(		
							.clk(clk),	//发送数据模块
							.rst_n(rst_n),
							.rx_data(rx_data_r),
							.rx_int(uart_tx_int),
							//.rx_int(rx_int_r),//发送的数据准备完毕
							.rs232_tx(rs232_tx),//串行发送
							.clk_bps(clk_bps_tx),
							.bps_start(bps_start_tx),
							.data_tx_done(data_tx_done)
						);
						
UART_APPLY		UART_APPLY(
							.ADC_DATA(ADC_DATA),//(ADC_DATA_temp),
							.clk(clk),
							.rst_n(rst_n),
							.rs232_data_rx(rs232_data_rx),
							.data_complete(data_tx_done),
							.rx_data(rx_data_r),
							.uart_tx_int(uart_tx_int),
							.pixel_cnt(pixel_cnt),
							.clk_adc(CLK_ADC),
							//.otr(OTR),
							//for debug use
							.pixel_buf_cnt_output(pixel_buf_cnt_output),
							.FIFO_r1_complete_output(FIFO_r1_complete_output),
							.FIFO_r2_complete_output(FIFO_r2_complete_output),
							.ADC_DATA_FIFO_JUDGE_output(ADC_DATA_FIFO_JUDGE_output),
							.pixel_rs232_cnt_output(pixel_rs232_cnt_output),
							.min_adc_data_output(min_adc_data_output)
						);
//UART CODE
//if(DAC_DATA_change) begin
SPI_DAC161		SPI_DAC161(
							.clk(clk),
							.rst(rst_n),
							.miso(SDO),
							.mosi(SDI),
							.sck(SCLK),
							.start(START_EN),
							.data_in(DAC_DATA),
							//.output[23:0] data_out,
							//.output busy,
							.new_data(CSB),    //new_data pin to CS pin of DAC
							.clrb(CLRB),
							.ldacb(LDACB),
							.min_adc_data_output(min_adc_data_output)
							);
//							end
/*TB_SPI_MasSlv		TB_SPI_MasSlv(
							.rstb(rst_n),
							.clk(clk),
							.din(din),
							.dout(dout),
							.m_tdat(m_tdat),
							.Mrdata(Mrdata)
							);*/
	localparam kp = 1;
/*always @ (posedge clk) begin
	//ADC_DATA <= 
	if((ADC_DATA < 700 ) && (ADC_DATA > 100))
	DAC_DATA_2 <= DAC_DATA_2;
	else begin
	DAC_DATA_2 <= DAC_DATA_2 + kp * (ADC_DATA - 400);
	end
end*/
  always @(posedge CSB) begin

/*	if((min_adc_data_output < 600 ) && (min_adc_data_output > 200))
	DAC_DATA_2 <= DAC_DATA_2;
	else begin
	DAC_DATA_2 <= DAC_DATA_2 + kp * (min_adc_data_output - 400);
	end*/
		count_laser <= count_laser + 2'b1;
	ADC_DATA_REV = 4095 - ADC_DATA;
	min_adc_data_output_REV = 4095 - min_adc_data_output;
	 //if (count_laser < {5{1'b1}}) begin
	 case(count_laser)
	 3: begin
      DAC_DATA <= 24'b00000001_00000000_00000000;//CLR
		//count_laser <= 3;
    end
	/* 4: begin
      DAC_DATA <= 24'b00110000_00000001_00000000;//PD
    end
	 6: begin
      DAC_DATA <= 24'b00110000_00000000_00000001;//PD
    end*/
	 /*5: begin
      DAC_DATA <= 24'b10010000_00000000_00000000;//READ CONFIG
		//count_laser <= 4;
    end
	 7: begin
      DAC_DATA <= 24'b10010000_00000000_00000000;//READ CONFIG
		//count_laser <= 6;
    end
	 8: begin
      DAC_DATA <= 24'b00110000_00000000_00000000;//PD-exit
    end
	 9: begin
      DAC_DATA <= 24'b00000001_00000000_00000000;//CLR
		//count_laser <= 3;
    end
    10: begin
      //DAC_DATA <= 24'b00001000_11111111_11111111;
		DAC_DATA <= 24'b00101000_00000000_11111110;//SWB write through
    end*/
	 11: begin
      //DAC_DATA <= 24'b00011000_00000000_00000001;
		//DAC_DATA <= 24'b00010000_01111111_11111110;//WRUP
		DAC_DATA_1 = 8'b00010000;//WRUP
		//DAC_DATA_2 <= 35000;
		//DAC_DATA_2 <= (4096 - ADC_DATA)*39000/4096;//change dac output
		if((min_adc_data_output_REV <= 3700) && (min_adc_data_output_REV >= 3300))
		DAC_DATA_2 <= DAC_DATA_2;
		else begin
		if(DAC_DATA_2 > 65490) DAC_DATA_2 <= 65490;//设定DAC输出上限，防止溢出，并避免将值锁定
			else begin
//				if(DAC_DATA_2 < 3300)
				DAC_DATA_2 <= DAC_DATA_2 + (1* (3500 - ADC_DATA_REV))/100;//注意只能化整后处理
//				if(DAC_DATA_2 > 3700)
//				DAC_DATA_2 <= DAC_DATA_2 - (1* (ADC_DATA_REV - 3500))/1000;
				end
			end
		
		DAC_DATA[23:0] <= {DAC_DATA_1,DAC_DATA_2};
		count_laser <= 11;
    end
	 12: begin
      //DAC_DATA <= 24'b00011000_00000000_00000001;
		DAC_DATA <= 24'b10001000_00000000_00000000;//RDDO READ PREREG REGISTER
		//count_laser <= 12;
    end
	 13: begin
      //DAC_DATA <= 24'b00011000_00000000_00000001;
		DAC_DATA <= 24'b10011000_00000000_00000000;//RDIN READ DACREG REGISTER
		count_laser <= 11;
    end
	 14: begin
      //DAC_DATA <= 24'b00011000_00000000_00000001;
		DAC_DATA <= 24'b00011000_00000000_00000001;//LDAC
		//count_laser <= 12;
    end	 
	 default: DAC_DATA <= 24'b0;
	endcase
	 
	 DAC_DATA_r <= DAC_DATA;
	 //START_EN <= !( DAC_DATA_r == DAC_DATA);
	//DAC_DATA[23:0] <= {DAC_DATA_1,DAC_DATA_2};
  end

endmodule 