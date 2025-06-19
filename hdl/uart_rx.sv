module uart_rx#(parameter  BYTESIZES = 8, OVERSAMPLING = 16, BAUDRATE = 115200,	COUNTER_CLOCK_INPUT = 50_000_000)(
    input  logic                     clock       ,
    input  logic                     nreset      ,
    input  logic                     sdata       ,
    output logic [BYTESIZES-1:0]    dataout        
);
enum {IDLE, START, R_DATA, STOPBIT} next_fsm,current_fsm;
logic clock_out, sample_center_bit;
logic [BYTESIZES-1:0]   px_bit, next_px_bit,    counter_max_sampling;
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
        current_fsm <= IDLE ;
        px_bit      <= 	  0 ;
        dataout     <=    0 ;
        ena 	    <=    0 ;
    end
    else begin      
        tmp_sdata 			<= sdata                                                               ;
	    current_fsm         <= next_fsm                                                            ;
        px_bit              <= next_px_bit                                                         ;
		dataout[px_bit]     <= current_fsm == R_DATA ? sample_center_bit && tmp_sdata :dataout  ;        
        ena <= ena_next;
    end
end
always_comb case(current_fsm)
        IDLE:begin
            next_fsm 		= 	tmp_sdata  ? IDLE:  START	                                    ;
            ena_next 		= 	0									                            ;
            next_px_bit 	= 	0									                            ;
        end
		START:begin
            next_fsm 		=  counter_max_sampling != OVERSAMPLING-2  ? START:  R_DATA           ;
            ena_next 		= 	1												                ;
            next_px_bit 	= 	0								    			                ;		  
		end
        R_DATA:begin
            next_px_bit 	= px_bit != BYTESIZES && sample_center_bit  ? px_bit + 1: px_bit    ;
            next_fsm 	  	= px_bit == BYTESIZES && sample_center_bit  ? STOPBIT : R_DATA        ;
            ena_next 		= 1                                                                 ;
        end
        STOPBIT:begin
            next_fsm 		= sample_center_bit ? IDLE :  STOPBIT                               ;
			ena_next 		= 1                                                                 ;
            next_px_bit 	= 0                                                                 ;                             
		end
endcase    
endmodule
