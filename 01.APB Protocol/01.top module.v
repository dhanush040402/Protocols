
`include "master.v"
`include "slave1.v"
`include "slave2.v"

`timescale 1ns/1ps

module APB_protocol(
  input [8:0]apb_read_paddr,apb_write_paddr,
  input [7:0]apb_write_data,
  input pclk,preset,read_write,transfer,
  output [7:0] apb_read_dataout
);
  
  wire penable,psel1,psel2,pready1,pready2,pready,pwrite;
  wire [7:0]pwdata,prdata,prdata1,prdata2;
  wire [8:0]paddr;
  
  assign pready = paddr[8] ? pready2 : pready1;
  assign prdata = read_write ? (paddr[8] ? prdata2 : prdata1) : 8'bx;
  
  master m(
    .pclk(pclk),
    .preset(preset),
    .transfer(transfer),
    .pready(pready),
    .read_write(read_write),
    .penable(penable),
    .psel1(psel1),
    .psel2(psel2),
    .apb_read_paddr(apb_read_paddr),
    .apb_write_paddr(apb_write_paddr),
    .apb_write_data(apb_write_data),
    .apb_read_dataout(apb_read_dataout),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(prdata),
    .paddr(paddr) 
  );
  
  slave1 s1(
    .pclk(pclk),
    .preset(preset),
    .psel(psel1),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .pready1(pready1),
    .prdata1(prdata1)
  );
  
    slave2 s2(
    .pclk(pclk),
    .preset(preset),
    .psel(psel2),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .pready2(pready2),
    .prdata2(prdata2)
  );

endmodule 
