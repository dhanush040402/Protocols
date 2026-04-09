module spi_master #(
  parameter sys_clk = 50_000_000,
  parameter spi_clk = 10_000_000
)(
  input clk,
  input rst_n,
  input start,
  input [7:0]tx_data,
  output reg [7:0]rx_data,
  output reg done ,
  
  output reg mosi,
  output reg cs_n,
  output reg s_clk,
  input miso
);
  
  reg [7:0]tx_shift;
  reg [7:0]rx_shift;
  reg [1:0]state;
  reg [31:0]base_count;
  
  reg s_clk_prev;
  
  localparam N = sys_clk / spi_clk;
  reg [2:0] count;
  
  
  localparam idle = 2'd0;
  localparam transfer = 2'd1;
  localparam over = 2'd2;
  
  wire clk_rise;
  wire clk_fall;
  
  always @(posedge clk or negedge rst_n)begin
    if(!rst_n) s_clk_prev <= 0;
    else       s_clk_prev <= s_clk;
  end
  
  assign sclk_rise = (!s_clk_prev) & (s_clk);
  assign sclk_fall = (s_clk_prev) & (!s_clk);
  
  always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      base_count <= 0;
      s_clk <= 0;
    end
    else begin
      if(base_count == N-1)
        base_count <= 0;
      else
        base_count <= base_count + 1'b1;
      
      if (base_count < (N/2))
        s_clk <= 0;
      else
        s_clk <= 1;
    end
  end
  
   
  always @(posedge clk or negedge rst_n)begin
    
    if(!rst_n)begin
      s_clk <= 0;
      cs_n <= 1;
      mosi <= 0;
      state <= idle;
      done <= 0;
      count <= 0;
      tx_shift <= 0;
      rx_shift <= 0;
      
      
    end
    
    else begin
      
        case(state)
          
          
          idle : begin
            done <= 0;
            if(start)begin
              cs_n <= 0;
              tx_shift <= tx_data;
              rx_shift <= 0;
              state <= transfer;
            end
            else 
              state <= idle;
          end
          
          transfer : begin
            
            if(sclk_rise)begin
              rx_shift <= {rx_shift[6:0],miso};
              if(count == 7)begin
                state <= over;
              end
              else begin
                count <= count + 1'b1;
              end
            end
            
            if(sclk_fall)begin
              mosi <= tx_shift[7];
              tx_shift <= {tx_shift[6:0],1'b0};
            end
            
          end
          
          over : begin
            
            cs_n <= 1;
            state <= idle;
            rx_data <= rx_shift;
            count <= 0;
            done <= 1;
            
          end
          
          default : state <= idle;
          
        endcase
    end
  end
endmodule
  
  
  
  
  
