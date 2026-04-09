module tb;
  parameter sys_clk = 50_000_000;
  parameter spi_clk = 10_000_000;
  
  reg clk;
  reg rst_n;
  reg start;
  reg [7:0]master_tx_data;
  reg [7:0]slave_tx_data;
  
  wire [7:0]master_rx_data;
  wire [7:0]slave_rx_data;
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
    #10 clk = ~clk;
  end
  
  initial begin
    $dumpfile("spi.vcd");
    $dumpvars(0);
    
    rst_n = 1;
    
    #20;
    
    rst_n = 0;
    start = 1;
    
    master_tx_data = 8'd150;
    slave_tx_data = 8'd96;
    
    $display("Before Transmission");
    $display("master :",master_tx_data);
    $display("slave :",slave_tx_data);
    
    @(posedge done);
    @(posedge valid);
    
    start =0;
    
    $display("After Transmission");
    $display("master :",master_rx_data);
    $display("slave :",slave_rx_data);
    
    $finish;
  end
endmodule
