module counter#(parameter MODULET = 16)(
    input  logic clock           ,
    input  logic nreset          ,
    input  logic ena             ,
    output logic [$clog2(MODULET)-1:0] counter1,
    output logic counting_done

);
    logic [$clog2(MODULET)-1:0] next_counter, counter;
    always_ff@(posedge clock, negedge nreset)begin
        if(!nreset)counter <=0;
        else       counter <= next_counter;
    end
    assign next_counter  = counter == MODULET - 1 || !ena ? 0 : counter +1 ; 
    assign counting_done = counter == MODULET - 1 &&  ena                  ;
    assign counter1 = counter;
endmodule