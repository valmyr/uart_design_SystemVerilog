module baudRateGenerator#(parameter BAUDRATE = 9600,OVERSAMPLING  = 8, CLOCK_INPUT = 50_000_000) (
    input  logic nreset                  ,
    input   logic ena                    ,
    input   logic ena2                    ,
    input  logic clock                   ,
    output logic clock_out               ,
    output logic counting_done2          ,
	 output logic [32:0] counter_out	
);
    parameter STOPCOUNTER = CLOCK_INPUT/(2*BAUDRATE*OVERSAMPLING)+1;
    parameter WIDTH=$clog2(STOPCOUNTER);
    logic [WIDTH-1:0] counter, next_counter;
    logic counting_done1;
    logic counting_done3;
    counter #(.MODULET(STOPCOUNTER))inst_count1(
        
        .clock          (clock          ),
        .ena            (ena            ),
        .nreset         (nreset         ),
        .counting_done  (counting_done1 )
    );
    
    counter #(.MODULET(OVERSAMPLING))inst_count2(

        .clock          (clock_out      ),
        .ena            (ena2            ),
        .nreset         (nreset         ),
        .counting_done  (counting_done3 ),
        .counter1       (counter)
    );
    assign counting_done2 = counter == OVERSAMPLING/2-1;
	 assign counter_out = counter;
    logic next_clock;
    always_ff@(posedge clock, negedge nreset)
        if(!nreset)         clock_out <= 0          ;
        else                clock_out <= next_clock ;
    assign next_clock   =   ena ? (counting_done1 ? ~ clock_out: clock_out) : 0 ;
endmodule