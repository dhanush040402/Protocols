`timescale 1ns/1ps

module testbench;
  
  parameter tx_sys_clk = 40_000_000;
  parameter rx_sys_clk = 10_000_000;
  parameter baud_rate  = 9600;
  parameter data_width = 8;
  
  reg tx_clk;
  reg rx_clk;
  reg parity_en;
  reg odd_r_even_parity;
  reg rst;
  reg tx_en;
  reg rx;
  reg baud_en;
  reg [data_width-1:0]data_in;
  
  wire tx;
  wire busy;
  wire done;
  wire framing_error;
  wire parity_error;
  wire [data_width-1:0]data_out;
  
  
  uart #(.tx_sys_clk(tx_sys_clk),
         .rx_sys_clk(rx_sys_clk),
         .baud_rate(baud_rate),
         .data_width(data_width))
  dut(
    .tx_clk(tx_clk),
    .rx_clk(rx_clk),
    .rst(rst),
    .tx_en(tx_en), 
    .baud_en(baud_en),
    .parity_en(parity_en),
    .odd_r_even_parity(odd_r_even_parity),
    .rx(rx),
    .data_in(data_in),
    .tx(tx),
    .busy(busy),
    .done(done),
    .framing_error(framing_error),
    .parity_error(parity_error),
    .data_out(data_out)
  );
  
  always #12.5 tx_clk = ~tx_clk;
  
  always #50 rx_clk = ~rx_clk;
  
  assign #1 rx = tx; 
  
  initial begin
    $dumpfile("uart.vcd");
    $dumpvars(0);
    
    $monitor("data in = %0d | tx = %0b | busy = %0b | rx = %0b | data out = %0d | done = %0b | framing error = %0b | parity error =  %0b | t_state = %0d | r_state = %0d | Time = %0t ",data_in,tx,busy,rx,data_out,done,framing_error,parity_error,dut.transmit.state,dut.receive.state,$time);
    
    rst=0;
    baud_en=1;
    tx_en=0;
    parity_en=0;
    odd_r_even_parity=0;
    tx_clk=0;
    rx_clk=0;
    data_in=0;
    
    #100;
    rst=1;
    
    testcase(8'd250,0,1);
    testcase(8'd251,0,0);
    testcase(8'd252,0,1);
    #1000 $finish;
    
  end
    
  task testcase (input [data_width-1:0]data,input p_en,input p_type);
    begin
      @(posedge tx_clk);
      
      data_in=data;
      parity_en=p_en;
      odd_r_even_parity=p_type;
      
      $display("\n------------------------- Sending Data: %d | parity en & type  = %0d & %0s-----------------------\n", data, p_en, (p_type) ? "ODD" : "EVEN");
      
      tx_en=1;
      @(posedge busy);
      
      tx_en=0;
      @(posedge done);
      
      #100;
      
      if(data_out==data && !framing_error && !parity_error)begin
        $display("Successfully transfered and received | data out = %d ",data_out);
      end
      else
        $display("Error");
      
      #200;
    end
  endtask
  
endmodule
