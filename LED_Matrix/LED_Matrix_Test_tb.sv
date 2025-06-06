// Version 1.0

/*

Simplified testbench for LED_Matrix_Test.sv
Tests the four different modes using key combinations

*/

`include "./LED_defines.vh"
`timescale 1ns / 1ps

module LED_Matrix_Test_tb();


    parameter integer p_frequency           = 50_000_000    ;
    parameter integer p_pwm_bits            = 8             ;
    parameter integer p_row_num             = 8             ;
    parameter integer p_column_num          = 8             ;
    parameter integer p_control_num         = 3             ;

    parameter CLK_PERIOD = 20; // 50MHz clock = 20ns period

    // Signals
    reg     clk                                             ;
    reg     rst_n                                           ;
    reg     start                                           ;
    reg     w_key_2                                         ;
    reg     w_key_3                                         ;
    reg     w_key_4                                         ;
    
    wire    [p_row_num - 1 : 0]     w_row_anode             ;
    wire                            w_done                  ;

    wire    [p_control_num - 1 : 0]  w_column_cell   [0 : p_column_num - 1];
    

// DUT instance with individual column connections

LED_Matrix_Test #(

    .p_frequency        (p_frequency)                   ,
    .p_pwm_bits         (p_pwm_bits)                    ,
    .p_row_num          (p_row_num)                     ,
    .p_column_num       (p_column_num)                  ,
    .p_control_num      (p_control_num)

) DUT (

    .clk                (clk)                           ,
    .rst_n              (rst_n)                         ,
    .start              (start)                         ,
    
    .w_key_2            (w_key_2)                       ,
    .w_key_3            (w_key_3)                       ,
    .w_key_4            (w_key_4)                       ,
    .w_row_anode        (w_row_anode)                   ,
    .w_column_cell      (w_column_cell)                 ,

    .w_done             (w_done)
);





    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test sequence
    initial begin
        $display("=== LED Matrix Test Starting ===");
        
        // Initialize
        rst_n = 0;
        start = 0;
        w_key_2 = 1;
        w_key_3 = 1;
        w_key_4 = 1;
        
        // Reset
        #(CLK_PERIOD * 10);
        rst_n = 1;
        #(CLK_PERIOD * 5);
        
        // Test 1: Single LED (3'b011)
        $display("Test 1: Single LED Mode");
        w_key_2 = 0; w_key_3 = 1; w_key_4 = 1;
        start = 1;
        #CLK_PERIOD;
        start = 0;
        wait(w_done);
        $display("Single LED test - Row: %b", w_row_anode);
        rst_n = 0;
        #(CLK_PERIOD * 10);
        
        // Test 2: Row LED (3'b101)
        $display("Test 2: Row LED Mode");
        rst_n = 1;
        w_key_2 = 1; w_key_3 = 0; w_key_4 = 1;
        start = 1;
        #CLK_PERIOD;
        start = 0;
        wait(w_done);
        $display("Row LED test - Row: %b", w_row_anode);
        rst_n = 0;
        #(CLK_PERIOD * 10);
        

        // Test 3: PWM Mode (3'b001) - brief test
        $display("Test 3: PWM Mode (brief)");
        rst_n = 1;
        w_key_2 = 0; w_key_3 = 0; w_key_4 = 1;
        start = 1;
        #CLK_PERIOD;
        start = 0;
        
        // Run PWM for a short time
        #(CLK_PERIOD * 1000);
        rst_n = 0;
        $display("PWM test - Row: %b", w_row_anode);
        


        // Test 4: Water LED (3'b110) - with timeout
        $display("Test 4: Water LED Mode");
        rst_n = 1;
        w_key_2 = 1; w_key_3 = 1; w_key_4 = 0;
        start = 1;
        #CLK_PERIOD;
        start = 0;
        
        // Wait with simple timeout for water LED
        repeat(100_000) begin
            #CLK_PERIOD;
            if (w_done) begin
                $display("Water LED completed - Row: %b", w_row_anode);
                #(CLK_PERIOD * 10);
                $stop; // Break out of loop
            end
        end
        $display("Water LED timeout or completed");
        #(CLK_PERIOD * 10);
        $display("=== All Tests Complete ===");
        $finish;
        

    end

    // Simple monitoring
    initial begin
        $monitor("Time=%0d, Keys=%b%b%b, Row=%b, Done=%b", 
                 $time, w_key_2, w_key_3, w_key_4, w_row_anode, w_done);
    end

    // Waveform dump
    initial begin
        $dumpfile("LED_Matrix_Test_tb.vcd");
        $dumpvars(0, LED_Matrix_Test_tb);
    end

endmodule 