// Version 1.0

/*

*/

module spi_slave_wrapper_test #(

    parameter DATA_WIDTH = 8
)

(

    input  wire                     sys_clk         ,

    input  wire                     spi_clk         ,      
    input  wire                     w_spi_ss_n0     ,       
    input  wire                     w_spi_mosi      ,

    output wire                     w_spi_miso      ,
    output wire                     w_test_led

);


/*--------------------------------register-------------------------------------------*/

// SPI interface reg, temp  
reg                                 r_spi_ss_n0     ;
reg                                 r_spi_mosi      ;
reg                                 r_spi_miso      ;

reg     [DATA_WIDTH - 1 : 0]        r_data_mosi     ;
reg     [DATA_WIDTH - 1 : 0]        r_data_miso     ;

reg     [$clog2(DATA_WIDTH) : 0]    r_mosi_cnt      ;
reg     [$clog2(DATA_WIDTH) : 0]    r_miso_cnt      ;


// spi_bram reg

reg     [11 : 0]                    r_bram_addra    ;
reg     [7 : 0]                     r_bram_dina     ;
reg                                 r_bram_ena      ;
reg                                 r_bram_wea      ;

reg                                 r_bram_enb      ;
reg     [11 : 0]                    r_bram_addrb    ;


// STATE MAchine
reg                                 FLAG_SEL        ;

reg                                 r_test_led      ;


/*--------------------------------register-------------------------------------------*/



/*--------------------------------wire-----------------------------------------------*/

wire    [7 : 0]                     w_bram_doutb    ;
wire    [11 : 0]                    w_bram_addrb    ;


/*--------------------------------wire-----------------------------------------------*/






/*--------------------------------assign---------------------------------------------*/

// SPI interface
assign   w_spi_miso                 = r_spi_miso    ;   


// bram
assign w_bram_addrb                 = r_bram_addrb  ;


// Test led
assign w_test_led                   = r_test_led    ;

/*--------------------------------assign---------------------------------------------*/


spi_bram spi_bram_0 (

    .clka       (spi_clk)                           ,
    .ena        (r_bram_ena)                        ,
    .wea        (r_bram_wea)                        ,
    .addra      (r_bram_addra)                      ,
    .dina       (r_bram_dina)                       ,

    .clkb       (1'b0)                              ,
    .enb        (1'b0)                              ,
    .addrb      (12'h000)                           ,
    .doutb      ()

);




always @(*) begin
    
    FLAG_SEL = ~r_spi_ss_n0; 
    
    // r_test_led = ~r_spi_ss_n0;
end


always @(*) begin
    
    r_spi_ss_n0  = w_spi_ss_n0 ;
    r_spi_mosi   = w_spi_mosi  ;
end




initial begin

    r_spi_ss_n0 <= 'd1;
    r_spi_mosi  <= 'd0;
    r_spi_miso  <= 'd0;
    r_data_mosi <= 'd0;
    r_data_miso <= 'd0;
    r_mosi_cnt  <= 'd0;
    r_miso_cnt  <= 'd0;
    FLAG_SEL    <= 'd0;
    r_bram_addra<= 'd0;
    r_bram_dina <= 'd0;
    r_bram_ena  <= 'd0;
    r_bram_wea  <= 'd0;

end






// Master output slave input - receiver logic

always @(posedge spi_clk) begin
    
    if(FLAG_SEL) begin

        if(r_mosi_cnt == DATA_WIDTH - 1) begin
            
            r_data_mosi[DATA_WIDTH-1-r_mosi_cnt] <= r_spi_mosi;
            
            if({r_data_mosi[DATA_WIDTH-1:1], r_spi_mosi} == 8'hFF) begin
                r_test_led <= 1'b1;
            end
            else if({r_data_mosi[DATA_WIDTH-1:1], r_spi_mosi} == 8'h00) begin
                r_test_led <= 1'b0;
            end
            
            r_bram_dina <= {r_data_mosi[DATA_WIDTH-1:1], r_spi_mosi};
            r_bram_ena  <= 1'b1;
            r_bram_wea  <= 1'b1;
            
            if(r_bram_addra <= 12'hFFF) begin
                r_bram_addra <= r_bram_addra + 1'b1;
            end else begin
                r_bram_addra <= 12'h000;
            end
            
            r_mosi_cnt <= 'd0;
        end

        else begin

            r_data_mosi[DATA_WIDTH-1-r_mosi_cnt] <= r_spi_mosi;
            r_mosi_cnt <= r_mosi_cnt + 1'b1;
        end
    end

    else begin

        r_mosi_cnt <= 'd0;
        r_bram_ena <= 1'b0;
        r_bram_wea <= 1'b0;
    end
end


// Bram input logic

// always @(posedge sys_clk) begin
    
//     if(r_mosi_cnt >= DATA_WIDTH - 1) begin
        
//         r_bram_dina     <= r_data_mosi              ;
//         r_bram_ena      <= 'd1                      ;
//         r_bram_wea      <= 'd1                      ;

//         if(r_data_mosi == 8'hFF) begin

//             r_test_led <= 'd1;
//         end

//         else if (r_data_mosi == 8'h00) begin

//             r_test_led <= 'd0;
//         end

//         if(r_bram_addra <= 12'hFFF) begin

//             r_bram_addra    <= r_bram_addra + 'd1   ; 
//         end

//         else begin
            
//             r_bram_addra    <= 'd0                  ; 
//         end
//     end
// end






// Master input slave output - sender logic

always @(posedge spi_clk) begin
    
    if(FLAG_SEL) begin
        
        r_spi_miso <= r_data_miso[r_miso_cnt]; 
        r_miso_cnt <= r_miso_cnt + 'd1;


        // if(r_spi_miso == 'b1) begin

        //     r_test_led <= 'd1;
        // end

        // else if (r_spi_miso == 'b0) begin

        //     r_test_led <= 'd0;
        // end




        if(r_miso_cnt >= DATA_WIDTH) begin
            
            r_miso_cnt <= 'd0; 
        end
    end

    else begin
        
        r_miso_cnt <= 'd0;
    end
end



endmodule
