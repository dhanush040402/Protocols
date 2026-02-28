//`timescale 1ns/1ps

module rx_baud_generator #(
  parameter rx_sys_clk=50000000,
  parameter baud_rate=9600
)(
  input clk,rst,baud_en,
  output reg rx_tick
);
  
  localparam integer rx_cycle = rx_sys_clk / (baud_rate*16);
  localparam rx_bit = $clog2(rx_cycle);
  reg [rx_bit-1:0]rx_count;
  
  always @(posedge clk or negedge rst)begin
      
    if(!rst)begin
      rx_tick<=0;
      rx_count<=0;
    end
      
    else if(baud_en)begin
      if(rx_count==rx_cycle-1)begin
        rx_count<=0;
        rx_tick<=1;
      end
      else begin
        rx_tick<=0;
        rx_count<=rx_count+1;
      end
      
    end
      
  end
  
endmodule
  
  
  
    
