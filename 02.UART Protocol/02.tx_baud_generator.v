//`timescale 1ns/1ps

module tx_baud_generator #(
  parameter tx_sys_clk=50000000,
  parameter baud_rate=9600
)(
  input clk,rst,baud_en,
  output reg tx_tick
);
  
  localparam integer tx_cycle = tx_sys_clk / baud_rate;
  
  localparam tx_bit = $clog2(tx_cycle);
  
  reg [tx_bit-1:0]tx_count;
  
  always @(posedge clk or negedge rst)begin
    
    if(!rst)begin
      tx_tick<=0;
      tx_count<=0;
    end
    
    else if(baud_en)begin
      if(tx_count == tx_cycle-1)begin
        tx_count<=0;
        tx_tick<=1;
      end
      else begin
        tx_tick<=0;
        tx_count<=tx_count+1;
      end
      
    end
    
  end
  
endmodule
