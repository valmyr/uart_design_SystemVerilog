`timescale 10ns/10ns
module tb;
    logic clock, nreset,nreset2,sdata,clock_out;
    logic [11:0] dataout,regds;
    logic [11:0] tmpdata;
    logic [7:0] tmpdata_frame;
    logic h;
    uart_rx rx(
        .clock(clock)       ,
        .nreset(nreset)     ,
        .sdata(sdata)       ,
        .pdataout(dataout)           
    );
    baudRateGenerator #(.BAUDRATE(9600),.OVERSAMPLING(1),.CLOCK_INPUT(50_000_000)) tx(
    .nreset(nreset)                 ,
    .ena   (1'b1)                   ,
    .clock  (clock)                 ,
    .clock_out(clock_out)           ,
    .ena2(1'b1),
    .counting_done2()               
);

// uart_rxfun#(
// 	.CLK_FRE(50),      //clock frequency(Mhz)
// 	.BAUD_RATE(9600) //serial baud rate
// )
// //  refuart
// // (
// // 	.clk(clock),              //clock input
// // 	.rst_n(nreset),            //asynchronous reset input, low active 
// // 	.rx_data(),          //received serial data
// // 	.rx_data_valid(),    //received serial data is valid
// // 	.rx_data_ready(h),    //data receiver module ready
// // 	.rx_pin(sdata)            //serial data input
// // );


/*

1011_0111
0101_1010
*/
    initial tmpdata =12'b1_1111_0101_011;
    assign tmpdata_frame = tmpdata[10:3];

    always_ff@(posedge clock_out, negedge nreset)begin
        if(!nreset)begin
            regds <= 0;
            h <=0;
            nreset2 <=0;
        end
        else begin
            regds <= regds +1;

            sdata <= tmpdata[regds];
            h <= 1;
            nreset2 <=1;
            if(regds >= 23) $finish;
        end
    end 
    initial begin
         clock = 0;
         nreset = 0;
         #1 nreset =1;
         #2_000_000_000 $finish;
    end
    always #10ns clock = ~ clock;
endmodule