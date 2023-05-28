
module top(
    input               i_clk16,
    output [7:0]        o_leds,
	output              o_adc_clk_out,
	input               i_adc_clk
);

reg [25:0] led_cnt;

assign o_adc_clk_out = i_clk16;

always @(posedge i_adc_clk) begin
    led_cnt  <= led_cnt + 1'b1;
end

assign o_leds = led_cnt[25:18];

endmodule
