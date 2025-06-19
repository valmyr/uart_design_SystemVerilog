module uart_tx#(parameter  BYTESIZES = 8, OVERSAMPLING = 1, BAUDRATE = 115200,	COUNTER_CLOCK_INPUT = 50_000_000)(
    input  logic                     clock       ,
    input  logic                     nreset      ,
    input logic                      valid       ,
    input  logic  [BYTESIZES-1:0]   data       ,
    output logic                      sdata        
);
logic clock_out;
logic [BYTESIZES-1:0]   px_bit, next_px_bit,    counter_max_sampling;
logic [BYTESIZES-1+3:0] pframe_data;
logic ena,ena_next;
logic tmp_sdata;
baudRateGenerator #(.BAUDRATE(BAUDRATE),.OVERSAMPLING(OVERSAMPLING), .CLOCK_INPUT(COUNTER_CLOCK_INPUT)) boudrategenerator_inst (
    .nreset        (nreset        		)     ,        
    .ena           (ena          		)     ,        
    .clock         (clock         	    )     ,           
	.counter_out   (counter_max_sampling)     ,
    .clock_out     (clock_out     		)     ,            
    .counting_done2(sample_center_bit)     
);
always_ff@(posedge clock_out, negedge nreset) begin
    if(!nreset)begin 
        px_bit      <= 	  0 ;
    end
    else begin      
		  if(px_bit==0 && valid) sdata <= 1;
		  else if(px_bit==1)    sdata <=0;
		  else if(px_bit==10)   sdata <=1;
		  else sdata <= data[px_bit];
        px_bit    <= (valid && px_bit != BYTESIZES+2) ? px_bit+1 : 0;        
    end
end
assign pframe_data = valid ? {1'b1,data,2'b11}: 0;
endmodule
