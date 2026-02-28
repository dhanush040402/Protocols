//`timescale 1ns/1ps

module receiver #(parameter data_width=8)(
  input clk,rst,rx,rx_tick,odd_r_even_parity,parity_en,
  output reg done,framing_error,parity_error,
  output reg [data_width-1:0]data_out
);
  
  localparam data_count_width = $clog2(data_width);
  
  reg[data_count_width-1:0]data_count;
  reg[data_width-1:0]shift_reg;
  reg[3:0]rx_tick_count;
  
  parameter [2:0] IDLE=0,START=1,DATA=2,PARITY=3,STOP=4;
  reg [2:0] state;
  
  always @(posedge clk or negedge rst)begin
    
    if(!rst)begin
      state 		<= IDLE;	
      data_count 	<= 0;			
      rx_tick_count <= 0;
      data_out 	 	<= 0;
      parity_error	<= 0;
      framing_error	<= 0;
      done			<= 0;
    end
    
    else if(rx_tick) begin
      done <= 0;
      case(state)
        
        IDLE : begin
          rx_tick_count <= 0;
          data_count 	<= 0;			
          parity_error	<= 0;
      	  framing_error	<= 0;
          if(rx == 0)
            state <= START; 		
        end
        
        START : begin
          if(rx_tick_count==7)begin
            if(rx==0)begin
              state<=DATA;
              rx_tick_count<=0;
              data_count<=0;
            end
            else 
              state<=IDLE;
          end
          else 
            rx_tick_count<=rx_tick_count+1;
        end
        
        DATA : begin
          if(rx_tick_count==15)begin
            shift_reg[data_count]<=rx;
            rx_tick_count<=0;
            if(data_count==data_width-1)begin
              data_count<=0;
              state<=(parity_en) ? PARITY : STOP;
            end
            else
              data_count<=data_count+1;
          end
          else
            rx_tick_count<=rx_tick_count+1;
        end
        
        PARITY : begin
          if(rx_tick_count==15)begin
            rx_tick_count<=0;
            parity_error<=(odd_r_even_parity) ? (^shift_reg != rx) : (~(^shift_reg) != rx);
            state<=STOP;
          end
          else
            rx_tick_count<=rx_tick_count+1;
        end
        
        STOP : begin
          if(rx_tick_count==15)begin
            if(rx==1)begin
              done<=1;
              data_out<=shift_reg;
              rx_tick_count<=0;
              state<=IDLE;
            end
            else
              framing_error<=(rx!=1);
          end
          else 
            rx_tick_count<=rx_tick_count+1;
        end
        
        default : state<=IDLE;
        
      endcase
    end
  end
endmodule
        
        
        
        
