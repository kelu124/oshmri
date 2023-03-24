
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
    output [7:0]        o_leds
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

reg  [DATA_W-1:0] rd_data;
reg  [23:0]       wr_len;//in shorts
reg  [DATA_W-1:0] wr_data;
reg               led_mode;
reg  [25:0]       led_cnt;
reg  [7:0]        led_data;
reg  [1:0]        state;

localparam IDLE   = 2'd0;
localparam RD_CMD = 2'd1;
localparam DECODE = 2'd2;
localparam WR_ADC = 2'd3;

always@(posedge i_ft_clk or posedge rst)begin
	if(rst)begin
		o_ft_oe_n <= 1;
		o_ft_rd_n <= 1;
		state     <= IDLE;
		rd_data   <= 0;
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
				state     <= (io_ft_data[15:12]==3) ? WR_ADC : IDLE;
			end
			WR_ADC  : begin
				o_ft_oe_n <= 1;
				o_ft_rd_n <= 1;
				state     <= (wr_len!=0) ? WR_ADC : IDLE;
			end
			default : begin
				o_ft_oe_n <= 1;
				o_ft_rd_n <= 1;
				state     <= IDLE;
			end
		endcase
		rd_data <= (state==DECODE) ? io_ft_data : 0;
	end
end

always @(posedge i_ft_clk) begin
    if (rst) begin
		wr_len        <= 0;
		wr_data       <= 0;
		o_ft_wr_n     <= 1;
    end else if(rd_data[15:12]==1)begin
		wr_len[11:0]  <= rd_data[11:0];
		wr_data       <= 0;
		o_ft_wr_n     <= 1;
    end else if(rd_data[15:12]==2)begin
		wr_len[23:12] <= rd_data[11:0]; 
		wr_data       <= 0;
		o_ft_wr_n     <= 1;
	end else if(state==WR_ADC && wr_len!=0 && i_ft_txe_n==0)begin
		wr_len        <= wr_len - 1;
		wr_data       <= wr_data + 1;
		o_ft_wr_n     <= 0;
    end else begin
		wr_len        <= 0;
		wr_data       <= 0;
		o_ft_wr_n     <= 1;
	end
end

assign io_ft_data = (o_ft_oe_n) ? wr_data            : {DATA_W{1'bZ}};
assign io_ft_be   = (o_ft_oe_n) ? {BE_W{~o_ft_wr_n}} : {BE_W  {1'bZ}};

//LEDs

always @(posedge i_ft_clk) begin
    if (rst) begin
		led_mode <= 0;
		led_data <= 0;
    end else if(rd_data[15:12]==8)begin
		led_mode <= rd_data[8];
		led_data <= rd_data[7:0]; 
	end
end

always @(posedge i_clk16) begin
    if (rst) begin
        led_cnt  <= 0;
    end else begin
        led_cnt  <= led_cnt + 1'b1;
    end
end

assign o_leds = led_mode ? led_cnt[25:18] : led_data;

endmodule
