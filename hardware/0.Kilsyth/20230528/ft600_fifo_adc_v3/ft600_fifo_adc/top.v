
module top #(
    parameter DATA_W = 16,
    parameter BE_W = 2
)(
    input               i_clk16,i_ft_clk,
    input               i_ft_rxf_n,
    input               i_ft_txe_n,
    output reg          o_ft_oe_n,
    output reg          o_ft_rd_n,
    output reg          o_ft_wr_n,
    inout  [BE_W-1:0]   io_ft_be,
    inout  [DATA_W-1:0] io_ft_data,
    output [7:0]        o_leds,
	output reg          o_adc_clk_out,
	input               i_adc_clk,
	input  [9:0]        i_adc_data,
	output              o_ft_gpio1
);

// Synchronous active high reset
reg [5:0] reset_cnt = 0;
reg rst = 1;
always @(posedge i_ft_clk) begin
    if (reset_cnt < 1) begin
        rst       <= 1;
        reset_cnt <= reset_cnt + 1;
    end else begin
        rst       <= 0;
    end
end

// transfer the data with TXEn and receive with RXFn

reg  [23:0]       wr_len;//in shorts
reg  [DATA_W-1:0] wr_data;
reg               wr_done;
reg               led_mode;
reg  [25:0]       led_cnt;
reg  [7:0]        led_data;
reg  [2:0]        state;

reg         adc_trig;
reg         adc_trig_toggle;
reg         adc_trig_sync1;
reg         adc_trig_sync2;
reg         adc_trig_sync3;
reg         adc_trig_cdc;

reg  [15:0] adc_mem [8191:0];
reg  [12:0] adc_rd_addr;
reg  [15:0] adc_rd_data;
reg         adc_wr_en;
reg  [12:0] adc_wr_addr;
wire [15:0] adc_wr_data;

reg         adc_done;
reg         adc_done_toggle;
reg         adc_done_sync1;
reg         adc_done_sync2;
reg         adc_done_sync3;
reg         adc_done_cdc;

localparam IDLE        = 3'd0;
localparam RD_CMD      = 3'd1;
localparam DECODE      = 3'd2;
localparam WR_ADC_CNT  = 3'd3;
localparam LOOPBACK    = 3'd4;
localparam ADC_CAPTURE = 3'd5;
localparam WR_ADC_DATA = 3'd6;

always@(posedge i_ft_clk or posedge rst)begin
	if(rst)begin
		o_ft_oe_n <= 1;
		o_ft_rd_n <= 1;
		state     <= IDLE;
	end else begin
		case(state)
			IDLE    : begin
				if(i_ft_rxf_n==0)begin
					o_ft_oe_n <= 0;
					o_ft_rd_n <= 1;
					state     <= RD_CMD;
				end else begin
					o_ft_oe_n <= 1;
					o_ft_rd_n <= 1;
					state     <= IDLE;
				end
			end
			RD_CMD  : begin
				if(i_ft_rxf_n==0)begin
					o_ft_oe_n <= 0;
					o_ft_rd_n <= 0;
					state     <= DECODE;
				end else begin
					o_ft_oe_n <= 0;
					o_ft_rd_n <= 1;
					state     <= RD_CMD;
				end
			end
			DECODE  : begin
				o_ft_oe_n <= 1;
				o_ft_rd_n <= 1;
				case(io_ft_data[15:12])
				3 : state <= WR_ADC_CNT;
				7 : state <= LOOPBACK;
				10: state <= ADC_CAPTURE;
				default : state <= IDLE;
				endcase
			end
			LOOPBACK: begin
				o_ft_oe_n <= 1;
				o_ft_rd_n <= 1;
				state     <= (wr_done==0) ? LOOPBACK : IDLE;
			end
			WR_ADC_CNT  : begin
				o_ft_oe_n <= 1;
				o_ft_rd_n <= 1;
				state     <= (wr_done==0) ? WR_ADC_CNT : IDLE;
			end
			ADC_CAPTURE: begin
				o_ft_oe_n <= 1;
				o_ft_rd_n <= 1;
				state     <= (adc_done_cdc) ? WR_ADC_DATA : ADC_CAPTURE;
			end
			WR_ADC_DATA : begin
				o_ft_oe_n <= 1;
				o_ft_rd_n <= 1;
				state     <= (wr_done==0) ? WR_ADC_DATA : IDLE;
			end
			default : begin
				o_ft_oe_n <= 1;
				o_ft_rd_n <= 1;
				state     <= IDLE;
			end
		endcase
	end
end

always @(posedge i_ft_clk) begin
    if (rst) begin
		wr_len        <= 0;
		wr_data       <= 0;
		wr_done       <= 0;
		o_ft_wr_n     <= 1;
    end else if(state==DECODE && io_ft_data[15:12]==1)begin
		wr_len[11:0]  <= io_ft_data[11:0];
		o_ft_wr_n     <= 1;
		wr_done       <= 0;
    end else if(state==DECODE && io_ft_data[15:12]==2)begin
		wr_len[23:12] <= io_ft_data[11:0]; 
		o_ft_wr_n     <= 1;
		wr_done       <= 0;
    end else if(state==DECODE && io_ft_data[15:12]==7)begin
		wr_len        <= 1; 
		wr_data       <= io_ft_data;
		o_ft_wr_n     <= 1;
		wr_done       <= 0;
    end else if(state==DECODE && io_ft_data[15:12]==10)begin
		wr_len        <= 8192;
		o_ft_wr_n     <= 1;
		wr_done       <= 0;
	end else if(state==WR_ADC_CNT && wr_len!=0 && i_ft_txe_n==0)begin
		wr_len        <= wr_len - 1;
		wr_data       <= wr_data + 1;
		o_ft_wr_n     <= 0;
		wr_done       <= wr_len == 1;
	end else if(state==WR_ADC_DATA && wr_len!=0 && i_ft_txe_n==0)begin
		wr_len        <= wr_len - 1;
		wr_data       <= adc_rd_data;
		o_ft_wr_n     <= 0;
		wr_done       <= wr_len == 1;
	end else if(state==LOOPBACK && wr_len!=0 && i_ft_txe_n==0)begin
		wr_len        <= wr_len - 1;
		o_ft_wr_n     <= 0;
		wr_done       <= wr_len == 1;
    end else begin
		o_ft_wr_n     <= 1;
	end
end

always @(posedge i_ft_clk) begin
	adc_rd_data <= adc_mem[adc_rd_addr];
    if (rst) begin
		adc_rd_addr <= 0;
    end else if(state==DECODE && io_ft_data[15:12]==10)begin
		adc_rd_addr <= 0;
	end else if(state==WR_ADC_DATA && wr_len!=0 && i_ft_txe_n==0) begin
		adc_rd_addr <= adc_rd_addr + 1;
	end
end

assign io_ft_data = (o_ft_oe_n) ? wr_data            : {DATA_W{1'bZ}};
assign io_ft_be   = (o_ft_oe_n) ? {BE_W{~o_ft_wr_n}} : {BE_W  {1'bZ}};

assign o_ft_gpio1 = 1'b0; //(state==ADC_CAPTURE);

//ADC
//o_adc_clk_out is i_ft_clk/2
always@(posedge i_ft_clk)begin
	o_adc_clk_out <= ~o_adc_clk_out;
end

always @(posedge i_ft_clk) begin
    if (rst) begin
		adc_trig <= 0;
    end else if(state==DECODE && io_ft_data[15:12]==10)begin
		adc_trig <= 1;
	end else begin
		adc_trig <= 0;
	end
end

// adc_trig pulse clockdomain crossing logic from i_ft_clk to i_adc_clk
always @(posedge i_ft_clk or posedge rst) begin
    if (rst) begin
		adc_trig_toggle <= 0;
    end else if(adc_trig)begin
		adc_trig_toggle <= ~adc_trig_toggle;
	end
end

always @(posedge i_adc_clk or posedge rst) begin
    if (rst) begin
		adc_trig_sync1 <= 0;
		adc_trig_sync2 <= 0;
		adc_trig_sync3 <= 0;
		adc_trig_cdc   <= 0;
    end else begin
		adc_trig_sync1 <= adc_trig_toggle;
		adc_trig_sync2 <= adc_trig_sync1;
		adc_trig_sync3 <= adc_trig_sync2;
		adc_trig_cdc   <= adc_trig_sync2 ^ adc_trig_sync3;
	end
end

//ADC Write address and Write Enable counter
//@64MHz 8192 Clocks = 128us
//@48MHz 8192 Clocks = 170.667us
always@(posedge i_adc_clk)begin 
  if(rst) begin
    adc_wr_addr <= 13'h1fff;
    adc_wr_en   <= 0;
    adc_done    <= 0;
  end else if(adc_trig_cdc) begin
    adc_wr_addr <= 0;
    adc_wr_en   <= 1;
    adc_done    <= 0;
  end else if(adc_wr_addr!=13'h1fff) begin
    adc_wr_addr <= adc_wr_addr + 1;
    adc_done    <= 0;
  end else if(adc_wr_addr==13'h1fff) begin
    adc_wr_en   <= 0;
	adc_done    <= adc_wr_en;
  end else begin
  	adc_done    <= 0;
  end
end

assign adc_wr_data = {6'd0,i_adc_data};	
always@(posedge i_adc_clk)begin
	if(rst)begin
		if(adc_wr_en)
			adc_mem[adc_wr_addr] <= adc_wr_data;
	end
end

// adc_done pulse clockdomain crossing logic from i_adc_clk to i_ft_clk
always @(posedge i_adc_clk or posedge rst) begin
    if (rst) begin
		adc_done_toggle <= 0;
    end else if(adc_done)begin
		adc_done_toggle <= ~adc_done_toggle;
	end
end

always @(posedge i_ft_clk or posedge rst) begin
    if (rst) begin
		adc_done_sync1 <= 0;
		adc_done_sync2 <= 0;
		adc_done_sync3 <= 0;
		adc_done_cdc   <= 0;
    end else begin
		adc_done_sync1 <= adc_done_toggle;
		adc_done_sync2 <= adc_done_sync1;
		adc_done_sync3 <= adc_done_sync2;
		adc_done_cdc   <= adc_done_sync2 ^ adc_done_sync3;
	end
end

//LEDs

always @(posedge i_ft_clk) begin
    if (rst) begin
		led_mode <= 0;
		led_data <= 0;
    end else if(state==DECODE && io_ft_data[15:12]==8)begin
		led_mode <= io_ft_data[8];
		led_data <= io_ft_data[7:0]; 
	end
end

always @(posedge i_clk16) begin
    if (rst) begin
        led_cnt  <= 0;
    end else begin
        led_cnt  <= led_cnt + 1'b1;
    end
end

assign o_leds[7:1] = led_mode ? led_cnt[25:19] : led_data[7:1];
assign o_leds[0]   = o_ft_gpio1;

endmodule
