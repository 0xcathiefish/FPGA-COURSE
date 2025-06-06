// Version 1.0

/*

*/

module spi_slave #(

    parameter DATA_WIDTH = 8
)

(

    input  wire                     spi_clk         ,      
    input  wire                     w_spi_ss_n0     ,       
    input  wire                     w_spi_mosi      ,

    output wire                     w_spi_miso    

);


/*--------------------------------register-------------------------------------------*/

// SPI interface reg, temp  
reg                                 r_spi_ss_n0     ;
reg                                 r_spi_mosi      ;
reg                                 r_spi_miso      ;

reg     [DATA_WIDTH - 1 : 0]        r_data_mosi     ;
reg     [DATA_WIDTH - 1 : 0]        r_data_miso     ;

reg     [$clog2(DATA_WIDTH) -1 : 0] r_mosi_cnt      ;
reg     [$clog2(DATA_WIDTH) -1 : 0] r_miso_cnt      ;


// STATE MAchine
reg                                 FLAG_SEL        ;


/*--------------------------------register-------------------------------------------*/




/*--------------------------------assign---------------------------------------------*/

// SPI interface
assign   w_spi_miso               = r_spi_miso   ;   

/*--------------------------------assign---------------------------------------------*/



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

end





// Selected logic

always @(*) begin
    
    if(r_spi_ss_n0 == 0) begin
        
        FLAG_SEL = 'd1;
    end

    else if(r_spi_ss_n0 == 1) begin
        
        FLAG_SEL = 'd0;
    end

    else begin
        
        FLAG_SEL = FLAG_SEL; 
    end
end




// Master output slave input - receiver logic

always @(posedge spi_clk) begin
    
    if(FLAG_SEL) begin

        if(r_mosi_cnt >= DATA_WIDTH) begin
            
            r_mosi_cnt <= 'd0;

        end

        else begin
            
            r_data_mosi[r_mosi_cnt] <= r_spi_mosi;
            r_mosi_cnt <= r_mosi_cnt + 'd1  ;
        end
    end

    else begin
        
        r_mosi_cnt <= 'd0;
    end
end



// Master input slave output - sender logic

always @(posedge spi_clk) begin
    
    if(FLAG_SEL) begin
        
        r_spi_miso <= r_data_miso[r_miso_cnt]; 
        r_miso_cnt <= r_miso_cnt + 'd1;

        if(r_miso_cnt >= DATA_WIDTH - 1) begin
            
            r_miso_cnt <= 'd0; 
        end
    end

    else begin
        
        r_miso_cnt <= 'd0;
    end
end



endmodule