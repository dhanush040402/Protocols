`timescale 1ns/1ps


module slave2(
  input pclk,preset,psel,penable,pwrite,
  input [7:0]paddr,pwdata,
  output reg pready2,
  output [7:0]prdata2
);
  
  reg [7:0]reg_addr;
  reg [7:0] mem [0:255];
  
  assign prdata2=mem[paddr[7:0]];
  
  always @(posedge pclk)begin
    
    if(!preset)
      pready2 <= 0;
    
     //read logic 
     
    else if(psel && penable && !pwrite)begin
      pready2 <= 1;
      reg_addr <= paddr[7:0];
    end
    
    //WRITE LOGIC
    
    else if(psel && penable && pwrite)begin
      pready2 <= 1;
      mem[paddr[7:0]] <= pwdata;
    end
    
    else
      pready2 <= 0;
    
  end
  
endmodule
