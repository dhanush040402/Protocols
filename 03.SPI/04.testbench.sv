module tb;
  parameter sys_clk = 50_000_000;
  parameter spi_clk = 10_000_000;
  
  reg clk;
  reg rst_n;
  reg start;
  reg [7:0] master_tx_data;
  reg [7:0] slave_tx_data;
  
  wire [7:0] master_rx_data;
  wire [7:0] slave_rx_data;
  wire valid;
  wire done;
  
  spi_top #(.sys_clk(sys_clk),.spi_clk(spi_clk)) spi(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .master_tx_data(master_tx_data),
    .master_rx_data(master_rx_data),
    .slave_tx_data(slave_tx_data),
    .slave_rx_data(slave_rx_data),
    .done(done),
    .valid(valid)
  );
  
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
  
  initial begin
    $dumpfile("spi.vcd");
    $dumpvars(0);
    
    rst_n = 0;
    start = 0;
    
    
    #50;  
    
    rst_n = 1; 
    master_tx_data = 8'd150;
    slave_tx_data = 8'd96;
    
    $display("Before Transmission");
    $display("master_tx_data: %0d", master_tx_data);
    $display("slave_tx_data: %0d", slave_tx_data);
    
    start = 1;
    
   
    @(posedge valid);
    @(posedge done);
    

    
    start = 0;
    
    $display("After Transmission");
    $display("master_rx_data: %0d", master_rx_data);
    $display("slave_rx_data: %0d", slave_rx_data);
    
    if(master_rx_data == slave_tx_data && slave_rx_data == master_tx_data)
      $display("TEST PASSED!");
    else
      $display("TEST FAILED!");
    #200;
    $finish;
  end
endmodule
