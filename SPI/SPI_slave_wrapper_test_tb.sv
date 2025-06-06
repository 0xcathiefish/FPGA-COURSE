// SPI Slave Testbench
`timescale 1ns / 1ns

module spi_slave_wrapper_test_tb();

    parameter DATA_WIDTH = 8;
    parameter CYCLE      = 2;


    reg     clk             ;
    reg     w_spi_ss_n0     ;
    reg     w_spi_mosi      ;

    wire    w_spi_miso      ;


spi_slave_wrapper_test #(

    .DATA_WIDTH     (DATA_WIDTH)

) uut

(
    .sys_clk         (clk)          ,
    .spi_clk         (clk)          , 
    .w_spi_ss_n0     (w_spi_ss_n0)  , 
    .w_spi_mosi      (w_spi_mosi)   ,
    .w_spi_miso      (w_spi_miso)   
);


// Clock

initial begin

    clk = 1;
    forever #(CYCLE/2) clk = ~clk;
end

initial begin
    
    w_spi_ss_n0 = 'd1;
    w_spi_mosi  = 'd0;
end


initial begin
    

    w_spi_ss_n0 = 'd0;

    # 1;

    w_spi_mosi = 'd1;

    # CYCLE;
    w_spi_mosi = 'd1;

    # CYCLE;
    w_spi_mosi = 'd1;

    # CYCLE;
    w_spi_mosi = 'd1;

    # CYCLE;
    w_spi_mosi = 'd1;

    # CYCLE;
    w_spi_mosi = 'd1;

    # CYCLE;
    w_spi_mosi = 'd1;

    # CYCLE;
    w_spi_mosi = 'd1;

    w_spi_ss_n0 = 'd1;

    # 20;
    $finish;
end

endmodule 