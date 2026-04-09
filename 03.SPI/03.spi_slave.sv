module spi_slave (
  input s_clk,
  input rst_n,
  input cs_n,
  input mosi,
  output reg miso,

  input [7:0]tx_data,
  output reg [7:0]rx_data,
  output reg valid
);
  reg [2:0] count;
  reg [7:0] tx_shift;
  reg [7:0] rx_shift;
  
  reg cs_n_prev;
  wire cs_n_fall;
  
  always @(posedge s_clk or negedge rst_n)begin
    if(!rst_n) cs_n_prev <= 1;
    else cs_n_prev <= cs_n;
  end
  
  assign cs_n_fall = (cs_n_prev) & (!cs_n);
  
  
  always @(posedge s_clk or negedge rst_n) begin
    if(!rst_n)begin
      rx_data <= 0;
      count <= 0;
      valid <= 0;
      rx_shift <= 0;
    end
    
    else if(!cs_n)begin
      rx_shift <= {rx_shift[6:0],mosi};
      if(count == 7)begin
        count <= 0;
        valid <= 1;
        rx_data <= {rx_shift[6:0],mosi};
      end
      else begin
        count <= count + 1'b1;
        valid <= 0;
      end
    end
    
    else begin
      rx_data <= 0;
      count <= 0;
      valid <= 0;
      rx_shift <= 0;
    end
  end
  
  always @(posedge s_clk or negedge rst_n)begin
    
    if(rst_n)begin
      tx_shift <= 0;
    end
    
    else if(cs_n_fall)begin
      tx_shift <= tx_data;
    end
    
    else if(!cs_n)begin
      tx_shift <= {tx_shift[6:0],1'b1};
    end
  end
  
  always @(negedge s_clk or negedge rst_n)begin
    
    if(rst_n)begin
      miso <= 0;
    end
    
    else if(!cs_n)begin
      miso <= tx_shift[7];
    end
    
    else begin
      miso <= 0;
    end
  end
  
endmodule
      
      
