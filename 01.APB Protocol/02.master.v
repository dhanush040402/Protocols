`timescale 1ns/1ps

module master (
  input [8:0]apb_write_paddr,apb_read_paddr,
  input [7:0]apb_write_data,prdata,
  input preset,pclk,read_write,transfer,pready,
  output reg psel1,psel2,
  output reg penable,pwrite,
  output reg [8:0]paddr,
  output reg [7:0]apb_read_dataout,pwdata
);
  
  
  reg [2:0]state,next;
  localparam [2:0] idle=0,setup=1,access=2;
  
  always @(posedge pclk or negedge preset)begin
    if(!preset)begin
      state<=idle;
      apb_read_dataout <= 0;
    end
    
    else begin
      state<=next;
      if(state == access && pready && read_write)
        apb_read_dataout<=prdata;
    end
    
  end
  
  always @(*)begin
    if(!preset)
      next=idle;
    
    else begin
      penable=0;
      psel1=0;
      psel2=0;
      pwrite=0;
      pwdata=0;
      paddr=0;
      next=state;
      
      
      
      case(state)
        idle: begin
          if(!transfer)
            next=idle;
          else
            next=setup;
        end
        
        setup: begin
          penable=0;
          pwrite=read_write;
          
          if(read_write)begin
            paddr=apb_read_paddr;
            pwdata=0;
          end
          else begin
            paddr=apb_write_paddr;
            pwdata=apb_write_data;
          end
          
          if(paddr[8]==0)begin
            psel1=1;
            psel2=0;
          end
          else begin
            psel1=0;
            psel2=1;
          end
          
          next=access;
          

        end
        
        access: begin
        
        penable = 1;
        pwrite = ~read_write;


        
           if(read_write)begin
          paddr = apb_read_paddr;
          pwdata = 0;
        end
        else begin
          paddr = apb_write_paddr;
          pwdata = apb_write_data;
        end
        
           if(paddr[8]==1'b0)begin
          psel1 = 1;
          psel2 = 0;
        end
        else begin
          psel1 = 0;
          psel2 = 1;
        end

           if(pready)begin
          if(transfer)
            next = setup;
          else
            next = idle;
        end
        else
          next = access;
        
      end
      
      default: next = idle;
      
    endcase
    
    end
  end
  
endmodule
