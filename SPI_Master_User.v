`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:08:06 10/25/2016 
// Design Name: 
// Module Name:    SPI_Master 
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
//DAC161S055 CSB = new_data, LDACB = 0, CLRB = 1, rst需要先置0复位, mosi输出数据, sck输出时钟，data_in输出24位数据（前8位为指令00001000,MSB first）
module SPI_DAC161 #(parameter CLK_DIV = 8)( //SPI分频频率需要和光斑亮度自适应控制策略的控制频率对应
    input clk,
    input rst,
    input miso,	
    output mosi,
    output sck,
    input start,
    input[23:0] data_in,
    output[23:0] data_out,
    output busy,
    output new_data,    //new_data pin to CS pin of DAC
	 output clrb,
	 output ldacb,
	 input min_adc_data_output
  );
   
  localparam STATE_SIZE = 2;
  localparam IDLE = 2'd0,
    WAIT_HALF = 2'd1,
    TRANSFER = 2'd2;
  reg clrb_r = 1;
  reg ldacb_r = 1;
  reg ldacb_k = 1;
  reg clrb_k = 1;
  reg [STATE_SIZE-1:0] state_d, state_q;
  reg [23:0] data_d, data_q;
  reg [CLK_DIV-1:0] sck_d, sck_q;
  reg mosi_d, mosi_q;	
  reg [4:0] ctr_d, ctr_q;
  reg new_data_d, new_data_q;
//  wire new_data_q;
  reg new_data_k;
  reg[7:0] cnt_sck = 0;
  reg[9:0] cnt_ldacb = 0;
  reg[9:0] cnt_clrb = 0;
  reg [23:0] data_out_d, data_out_q;
  reg[2:0] cnt_sck_clr=0;
  reg[2:0] cnt_sck_clr_2 = 0;
  reg miso_r;
  reg[11:0] min_adc_data_output_r;
  
  assign mosi = mosi_q;
  assign sck = ~((~sck_q[CLK_DIV-1])) | ((new_data_q));// & (state_q == TRANSFER)) ;
  assign busy = state_q != IDLE;
  assign data_out = data_out_q;
  assign new_data = new_data_k;
//  assign new_data_q = (ctr_q == 4'b0000) & (state_q == WAIT_HALF);
  //assign new_data = (ctr_q == 4'b0000) & (sck_q < 10'b0100000000);
  assign clrb = 1;//clrb_k;
  assign ldacb = 1;//ldacb_k;
  always @(posedge new_data_q) begin
  if(cnt_sck_clr < 4) cnt_sck_clr <= cnt_sck_clr + 1;
  else if(cnt_sck_clr == 4) cnt_sck_clr <= cnt_sck_clr;
  if(cnt_sck_clr_2 < 5) cnt_sck_clr_2 <= cnt_sck_clr_2 + 1;
  else if(cnt_sck_clr_2 == 5) cnt_sck_clr_2 <= cnt_sck_clr_2;
  end
  always @(*) begin
  //new_data_q = (ctr_q == 4'b0000) & (state_q == WAIT_HALF);
  new_data_q = ((ctr_d == 4'b0000) & (state_d == WAIT_HALF)) | ((ctr_q == 4'b0000) & (state_q == WAIT_HALF));
  if(cnt_sck_clr_2 == 5) begin
  ldacb_r <=  ~((state_d == WAIT_HALF) & (state_q == WAIT_HALF));
  end
  if(cnt_sck_clr == 3) begin
  clrb_r <=  ~((state_d == WAIT_HALF) & (state_q == WAIT_HALF));
  end  
  else clrb_r <= 1;
  end
  always @(posedge clk) begin
  min_adc_data_output_r <= min_adc_data_output;
   miso_r = miso;
	new_data_k <= new_data_q;
	ldacb_k <= ldacb_r;
	clrb_k <= clrb_r;
  if(new_data_q == 1) begin
	  if(cnt_sck_clr == 4) begin
/*		  //CSB new_data_k
		  if(cnt_sck == 8'd150) begin
		  new_data_k <= 1;
		  cnt_sck <= cnt_sck;
		  end
		  else if(cnt_sck < 8'd150) begin
		  cnt_sck <= cnt_sck + 1;
		  new_data_k <= 0;
		  end
		  //CLRB
		  if(cnt_clrb == 10'd500) begin
		  cnt_clrb <= cnt_clrb;
		  end
		  else if(cnt_clrb < 10'd500) begin
		  cnt_clrb <= cnt_clrb + 1;
		  end
		  if((cnt_clrb < 10'd500) && (cnt_clrb > 10'd170))begin
		  clrb_r <= 0;
		  end
		  else begin
		  clrb_r <= 1;
		  end*/
	  end
  
	if(cnt_sck_clr_2 == 5) begin
/*		  //LDACB
		  if(cnt_ldacb == 10'd6) begin
		  cnt_ldacb <= cnt_ldacb;
		  end
		  else if(cnt_sck < 10'd6) begin
		  cnt_ldacb <= cnt_ldacb + 1;
		  end
		  if((cnt_ldacb < 10'd4) && (cnt_ldacb > 10'd1))begin
		  ldacb_r <= 0;
		  end
		  else begin
		  ldacb_r <= 1;
		  end*/
		  //ldacb_r <= new_data_q & ((state_d == WAIT_HALF) & (state_q == WAIT_HALF));
	  end
  
  end
  else if(new_data_q == 0) begin
/*  new_data_k <= 0;
  cnt_sck <= 0;
  //ldacb_r <= 1;
  cnt_ldacb <= 0;
//  cnt_clrb <= 0;
//  clrb_r <= 1;*/
  end
  end
  
  always @(*) begin
    sck_d = sck_q;
    data_d = data_q;
    mosi_d = mosi_q;	
    ctr_d = ctr_q;
    new_data_d = 1'b0;
    data_out_d = data_out_q;
    state_d = state_q;
    if(new_data_k == 1) mosi_d = 0;
    case (state_q)
      IDLE: begin
        sck_d = 10'b0;              // reset clock counter
        ctr_d = 5'b0;              // reset bit counter
        if (start == 1'b1) begin   // if start command
          data_d = data_in;        // copy data to send
          state_d = WAIT_HALF;     // change state
        end
      end
      WAIT_HALF: begin
        sck_d = sck_q + 1'b1;                  // increment clock counter
        if (sck_q == {CLK_DIV{1'b1}}) begin  // if clock is half full (about to fall)
          sck_d = 1'b0;                        // reset to 0
          state_d = TRANSFER;                  // change state
        end
      end
      TRANSFER: begin
        sck_d = sck_q + 1'b1;                           // increment clock counter
        if (sck_q == 10'b0) begin                     // if clock counter is 0
          mosi_d = data_q[23];                           // output the MSB of data
        end else if (sck_q == {CLK_DIV-1{1'b1}}) begin  // else if it's half full (about to fall)
          data_d = {data_q[22:0], miso};                 // read in data (shift in)
        end else if (sck_q == {CLK_DIV{1'b1}}) begin    // else if it's full (about to rise)
          ctr_d = ctr_q + 1'b1;                         // increment bit counter
          if (ctr_q == 5'b10111) begin                    // if we are on the last bit
				mosi_d = 0;												//no data output
            state_d = IDLE;                             // change state
            data_out_d = data_q;                        // output data
            new_data_d = 1'b1;                          // signal data is valid
          end
        end
      end
    endcase
  end
   
  always @(posedge clk) begin
    if (!rst) begin
      ctr_q <= 5'b0;
      data_q <= 8'b0;
      sck_q <= 10'b0;
      mosi_q <= 1'b0;
      state_q <= IDLE;
      data_out_q <= 8'b0;
      //new_data_q <= 1'b0;
    end else begin
      ctr_q <= ctr_d;
      data_q <= data_d;
      sck_q <= sck_d;
      mosi_q <= mosi_d;
      state_q <= state_d;
      data_out_q <= data_out_d;
      //new_data_q <= new_data_d;
		//new_data_q <= (ctr_q == 4'b0000) & (state_q == WAIT_HALF);
    end
  end
   
endmodule