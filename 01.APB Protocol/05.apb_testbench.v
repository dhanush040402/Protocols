`timescale 1ns/1ps

module apb_tb;
  reg pclk,preset,read_write,transfer;
  reg [7:0]apb_write_data;
  reg [8:0]apb_read_paddr,apb_write_paddr;
  wire [7:0] apb_read_dataout;
  
  APB_protocol dut(
    .pclk(pclk),
    .preset(preset),
    .transfer(transfer),
	.read_write(read_write),
	.apb_read_paddr(apb_read_paddr),
    .apb_write_paddr(apb_write_paddr),
    .apb_write_data(apb_write_data),
    .apb_read_dataout(apb_read_dataout)
	);
  
  always #5 pclk=~pclk;
  
  initial begin
    $dumpfile("apb.vcd");
    $dumpvars(0,apb_tb);
    
    pclk=0;
    preset=0;
    read_write=0;
    transfer=0;
    apb_read_paddr=9'b0;
    apb_write_paddr=9'b0;
    apb_write_data=8'b0;
    
    #20;
    preset=1;
    
    // Write -- Slave1 (addr[8] = 0)
    apb_write(9'd5, 8'd69);
    apb_write(9'd10, 8'd24);

    // Write -- Slave2 
    apb_write(9'd269, 8'd121); // 260 -> MSB = 1
    apb_write(9'd310, 8'd100);

    // Read -- Slave1
    apb_read(9'd5);
    apb_read(9'd10);

    // Read -- Slave2
    apb_read(9'd269);
    apb_read(9'd310);

    #100;
    $finish;
    
    
  end
    
  task apb_write(input [8:0]addr,input [7:0]data);
    begin
      @(posedge pclk);
      transfer=1;
      read_write=0;
      apb_write_paddr=addr;
      apb_write_data=data;

      @(posedge pclk);
      @(posedge pclk);

      transfer=0;

      $display(" Write = Address = %0d | Data = %0d | Time = %0t |",apb_write_paddr,apb_write_data,$time);

    end
  endtask
    
  task apb_read(input [8:0]addr);
    begin
      @(posedge pclk);
      transfer=1;
      read_write=1;
      apb_read_paddr=addr;


      @(posedge pclk);
      @(posedge pclk);
    

      transfer=0;

      $display("Read = Address = %0d | Data = %0d | Time = %0t |",apb_read_paddr,apb_read_dataout,$time);

    end
  endtask
  
endmodule
