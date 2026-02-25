`timescale 1ns/1ps

module transmitter #(parameter data_width=8)(
  input clk,rst,tx_en,tx_tick,odd_r_even_parity,parity_en,
  input [data_width-1:0]data_in,
  output reg tx,busy
);
  
  localparam data_count_width = $clog2(data_width);
  reg [data_count_width-1:0]data_count;
  reg [data_width-1:0]shift_reg;
  reg parity_bit;
  
  parameter [2:0] IDLE=0,START=1,DATA=2,PARITY=3,STOP=4;
  reg [2:0] state;
  
  always @ (posedge clk or negedge rst)begin
    if(!rst)begin
      state<=IDLE;
      tx<=1;
      data_count<=0;
    end
    else begin
      
      case(state)
        IDLE: begin
          tx<=1;
          if(tx_en)begin
            shift_reg<=data_in;
            state<=START;
            parity_bit<=((odd_r_even_parity) ? ^data_in : ~(^data_in));
          end
        end
        
        START: begin
          tx<=1;
          if(tx_tick)begin
            data_count<=0;
            tx<=0;
            state<=DATA;
          end
        end
        
        DATA: begin
          if(tx_tick)begin
            tx<=shift_reg[data_count];
            if(data_count==data_width-1)begin
              data_count<=0;
              state<=(parity_en) ? PARITY : STOP;
            end
          end
          else begin
              data_count=data_count+1;
            end
          end
        
        PARITY: begin
          if(tx_tick)begin
            tx<=parity_bit;
            state<=STOP;
          end
        end
        
        STOP: begin
          if(tx_tick)begin
            tx<=1;
            state<=IDLE;
          end
        end
        
        default : state<=IDLE;
      
      endcase
      
    end
    
  end
  
  assign  busy = (state == ~IDLE);
  
endmodule
