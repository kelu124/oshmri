
//`define SPAM_MODE 1

module top #(
    parameter DATA_W = 16,
    parameter BE_W = 2
)(
    input               i_clk16,i_ft_clk,
    inout  [DATA_W-1:0] io_ft_data,
    output              o_ft_oe_n,
    output              o_ft_rd_n,
    output              o_ft_wr_n,
    input               i_ft_rxf_n,
    input               i_ft_txe_n,
    inout  [BE_W-1:0]   io_ft_be,
    output [7:0]        o_leds
);

wire clk;
assign clk = i_ft_clk;
// Synchronous active high reset
reg [5:0] reset_cnt = 0;
reg rst = 1;
always @(posedge clk) begin
    if (reset_cnt < 1) begin
        rst       <= 1;
        reset_cnt <= reset_cnt + 1;
    end else begin
        rst       <= 0;
    end
end

assign o_ft_oe_n = 1'b1;
assign o_ft_rd_n = 1'b1;
assign io_ft_be = {BE_W{~o_ft_wr_n}};

`ifdef SPAM_MODE // spaming with data all the time
    assign o_ft_wr_n = rst;

    reg [DATA_W-1:0] data_cnt;
    always @(posedge clk) begin
        if (rst) begin
            data_cnt <= 0;
        end else begin
            data_cnt <= data_cnt + 1;
        end
    end
    assign io_ft_data = {data_cnt[DATA_W-1:1], 1'b1};

assign o_leds[0] = 1;

`else // transfer the data with respect to TXEn
    reg wr_drv;
    always @(posedge clk) begin
        if (rst) begin
            wr_drv <= 1;
        end else begin
            wr_drv <= i_ft_txe_n;
        end
    end
    assign o_ft_wr_n = wr_drv;

    reg [DATA_W-1:0] data_cnt;
    always @(posedge clk) begin
        if (rst) begin
            data_cnt <= 0;
        end else if (!wr_drv) begin
            data_cnt <= data_cnt + 1;
        end
    end
    assign io_ft_data = data_cnt;

assign o_leds[0] = 0;

`endif

reg [25:0] led1_cnt;
always @(posedge i_clk16) begin
    if (rst) begin
        led1_cnt <= 0;
    end else begin
        led1_cnt <= led1_cnt + 1'b1;
    end
end

assign o_leds[7:1] = led1_cnt[25:19];

endmodule
