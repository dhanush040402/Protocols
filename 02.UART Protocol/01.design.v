`timescale 1ns/1ps

`include "tx_baud_generator.sv"
`include "rx_baud_generator.sv"
`include "transmitter.sv"
`include "receiver.sv"

module uart #(
  parameter tx_sys_clk = 40000000,
  parameter rx_sys_clk = 10000000,
  parameter baud_rate  = 9600,
  parameter data_width = 8
)(
  input tx_clk,
  input rx_clk,
  input parity_en,
  input odd_r_even_parity,
  input rst,
  input tx_en,
  input rx,
  input baud_en,
  input [data_width-1:0]data_in,

  output tx,
  output busy,
  output done,
  output framing_error,
  output parity_error,
  output [data_width-1:0]data_out
);
  
  wire tx_tick;
  wire rx_tick;
  
  tx_baud_generator #(.tx_sys_clk(tx_sys_clk),.baud_rate(baud_rate))
  tx_baud(
    .clk(tx_clk),
    .tx_tick(tx_tick),
    .baud_en(baud_en),
    .rst(rst)
  );
  
  rx_baud_generator #(.rx_sys_clk(rx_sys_clk),.baud_rate(baud_rate))
  rx_baud(
    .clk(rx_clk),
    .rx_tick(rx_tick),
    .baud_en(baud_en),
    .rst(rst)
  );
  
  transmitter #(.data_width(data_width))
  transmit(
    .clk(tx_clk),
    .rst(rst),
    .tx_en(tx_en),
    .tx_tick(tx_tick),
    .parity_en(parity_en),
    .odd_r_even_parity(odd_r_even_parity),
    .tx(tx),
    .busy(busy),
    .data_in(data_in)
  );
                
  receiver #(.data_width(data_width))
  receive(
    .clk(rx_clk),
    .rst(rst),
    .parity_en(parity_en),
    .odd_r_even_parity(odd_r_even_parity),
    .rx(rx),
    .rx_tick(rx_tick),
    .parity_error(parity_error),
    .framing_error(framing_error),
    .done(done),
    .data_out(data_out)
  );
  
endmodule
