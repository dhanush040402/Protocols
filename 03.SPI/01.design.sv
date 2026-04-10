//spi top module
`include "spi_master.sv"
`include "spi_slave.sv"

module spi_top #(
  parameter sys_clk = 50_000_000,
  parameter spi_clk = 10_000_000
)(
  input clk,
  input rst_n,
  input start,
  input [7:0]master_tx_data,
  input [7:0]slave_tx_data,
  
  output [7:0]master_rx_data,
  output [7:0]slave_rx_data,
  output valid,
  output done
);
  
  wire miso;
  wire mosi;
  wire s_clk;
  wire cs_n;
  
  spi_master #(.sys_clk(sys_clk),.spi_clk(spi_clk)) m1(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .tx_data(master_tx_data),
    .rx_data(master_rx_data),
    .done(done),
    .s_clk(s_clk),
    .miso(miso),
    .mosi(mosi),
    .cs_n(cs_n)
  );
  
  spi_slave s1(
    .rst_n(rst_n),
    .tx_data(slave_tx_data),
    .rx_data(slave_rx_data),
    .valid(valid),
    .s_clk(s_clk),
    .miso(miso),
    .mosi(mosi),
    .cs_n(cs_n)
  );
  
endmodule
