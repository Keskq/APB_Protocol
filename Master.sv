`timescale 1ns/1ns

module apb_master(
        input PRESETn,PCLK,READ_WRITE,transfer
        input PREADY,
      	input [7:0]apb_write_paddr,apb_read_paddr,
      	input [7:0] apb_write_data,PRDATA,         
      	output PSEL1,PSEL2,
      	output reg PENABLE,
      	output reg [7:0]PADDR,
      	output reg PWRITE,
      	output reg [7:0]PWDATA,apb_read_data_out); 


reg [1:0] state, next_state;
local param IDLE=2'b00, SETUP=2'b01, ACCSESS=2'b10;

always @(poseedge PCLK)  // avery time the clock rise
begin 
    if (!PRESETn)
	state <= IDLE;
    else 
	state <= next_state;
end

always_comb begin
    case(state)
	IDLE: begin
	    PENABLE= 0;
		if (!transfer)
		    next_state= IDLE;
		else
		    next_state= SETUP;
	end
	        
	SETUP: begin
	    PENABLE= 0;
	    if(READ_WRITE) begin
		    PADDR= apb_write_paddr;
		    PWDATA= apb_write_data;
		    PWRITE=1;
	    end
	    else begin
		    PADDR= apb_read_paddr;
		    PWRITE=0;
	    end
	    if (PADDR[8])
                    PSEL2 = 1;                
            else
                    PSEL1 = 1;
		
	    next_state = ACCESS;	
	end
		
	ACCESS: begin 
	    if (PSEL1 || PSEL2) begin
		     PENABLE = 1; 
		     if (PREADY) begin
			  if (READ_WRITE) begin     
			  end
			  else begin
			       apb_read_data_out = PRDATA;
			  end	
			  next_state = (transfer) ? SETUP : IDLE; 
		      end 
		      else begin
		        next_state = ACCESS; 
		      end
	    end
	    else begin
		    next_state= IDLE;
	    end
	end	
end	
			

