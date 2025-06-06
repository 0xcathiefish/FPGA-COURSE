// Version 1.0

/*
This is a test demo, to turn on a led light on the fpga board

*/

module LED_test(

    input       wire        clk,
    input       wire        rst,

    output      reg         led

);

reg     [31 : 0]    timer_cnt;

always @(posedge clk)   begin
    
    if(!rst) begin
        
        led <= 'b0;
        timer_cnt <= 32'd0;
    end

    else begin
        
        if(timer_cnt >= 32'd49_999_999) begin
            
            led <= ~led;
            timer_cnt <= 32'd0; 
        end

        else begin
            
            led <= led; 
            timer_cnt <= timer_cnt + 'd1; 
        end
    end

end


endmodule