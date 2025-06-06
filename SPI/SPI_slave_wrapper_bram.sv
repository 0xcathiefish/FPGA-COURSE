// Version 1.0

/*

*/

module spi_slave_wrapper #(

    // SPI Data
    parameter DATA_WIDTH                    = 8                                                     ,                                            


    // LED Matrix
    parameter integer p_frequency           = 50_000_000                                            ,   // System clk frequency
    parameter integer p_pwm_bits            = 8                                                     ,   // PWM resolution bits
    parameter integer p_row_num             = 8                                                     ,   // Matrix row num  
    parameter integer p_column_num          = 8                                                     ,   // Matrix column num
    parameter integer p_control_num         = 3                                                     ,   // Controlling pin num for each led
    parameter integer p_brightness_step_ms  = 10                                                        // Each brightness level duration in ms
)

(

    input   wire                            sys_clk                                                 ,
    input   wire                            rst_n                                                   ,

    // SPI wire                                                    
    input   wire                            w_tx_done                                               ,
    input   wire                            spi_clk                                                 ,      
    input   wire                            w_spi_ss_n0                                             ,       
    input   wire                            w_spi_mosi                                              ,

    output  wire                            w_spi_miso                                              ,


    // LED Matrix                                                      
    output  wire    [p_row_num - 1 : 0]     w_row_anode                                             ,
    output  wire    [p_control_num - 1 : 0] w_column_cell   [0 : p_column_num - 1]                  ,

    output wire                             w_test_led

);


/*--------------------------------register-------------------------------------------*/

// SPI interface reg, temp  
reg                                 r_spi_ss_n0                                                     ;
reg                                 r_spi_mosi                                                      ;
reg                                 r_spi_miso                                                      ;

reg     [DATA_WIDTH - 1 : 0]        r_data_mosi                                                     ;
reg     [DATA_WIDTH - 1 : 0]        r_data_miso                                                     ;

reg     [$clog2(DATA_WIDTH) : 0]    r_mosi_cnt                                                      ;
reg     [$clog2(DATA_WIDTH) : 0]    r_miso_cnt                                                      ;


// spi_bram reg                                             

reg     [11 : 0]                    r_bram_addra                                                    ;
reg     [7 : 0]                     r_bram_dina                                                     ;
reg                                 r_bram_ena                                                      ;
reg                                 r_bram_wea                                                      ;

reg                                 r_bram_enb                                                      ;
reg     [11 : 0]                    r_bram_addrb                                                    ;

// Cross-clock domain signals for BRAM write                                           
reg     [7:0]                       r_write_data                                                    ;
reg     [11:0]                      r_write_addr                                                    ;

// Cross-clock edge detection signals
reg     [2:0]                       r_write_req_sync                                                ; // Synchronizer chain for sys_clk domain  
reg                                 r_write_req_edge                                                ; // Edge detection signal

// Tx reg
reg                                 r_tx_done                                                       ;

// LED matrix                                               

reg                                 r_start                                                         ;
reg     [8 + p_row_num + p_column_num - 1 : 0]  r_instruction                                       ;

// STATE MAchine
reg                                 FLAG_SEL                                                        ;


reg                                 r_test_led                                                      ;

/*--------------------------------register-------------------------------------------*/



/*--------------------------------wire-----------------------------------------------*/

// Bram
wire    [7 : 0]                     w_bram_doutb                                                    ;
wire    [11 : 0]                    w_bram_addrb                                                    ;


// LED matrix           

wire    [p_row_num - 1 : 0]         w_row_anode_intermit                                            ; 
wire    [p_control_num - 1 : 0]     w_column_cell_intermit  [0 : p_column_num - 1]                  ;


/*--------------------------------wire-----------------------------------------------*/






/*--------------------------------assign---------------------------------------------*/

// SPI interface
assign   w_spi_miso                 = r_spi_miso                                                    ;   


// bram                                             
assign   w_bram_addrb               = r_bram_addrb                                                  ;


// LED Matrix               
assign   w_row_anode                = w_row_anode_intermit                                          ;
assign   w_column_cell              = w_column_cell_intermit                                        ;


// Test LED

assign w_test_led                   = r_test_led                                                    ;


/*--------------------------------assign---------------------------------------------*/


spi_bram spi_bram_0 (

    .clka                           (sys_clk)                                                       ,
    .ena                            (r_bram_ena)                                                    ,
    .wea                            (r_bram_wea)                                                    ,
    .addra                          (r_bram_addra)                                                  ,
    .dina                           (r_bram_dina)                                                   ,
        
    .clkb                           (sys_clk)                                                       ,
    .enb                            (r_bram_enb)                                                    ,
    .addrb                          (r_bram_addrb)                                                  ,
    .doutb                          (w_bram_doutb)

);



LED_Matrix #(

    .p_frequency                    (p_frequency         )                                          ,
    .p_pwm_bits                     (p_pwm_bits          )                                          ,
    .p_row_num                      (p_row_num           )                                          ,
    .p_column_num                   (p_column_num        )                                          ,
    .p_control_num                  (p_control_num       )                                          ,
    .p_brightness_step_ms           (p_brightness_step_ms)


) led_matrix_uut

(

    .clk                            (sys_clk)                                                       ,               
    .rst_n                          (rst_n)                                                         ,
    .start                          (r_start)                                                       ,

    .w_instruction                  (r_instruction)                                                 ,
    .w_row_anode                    (w_row_anode_intermit)                                          ,
    .w_column_cell                  (w_column_cell_intermit)         

);

// FLAG SELECTED logic

always @(*) begin
    
    FLAG_SEL = ~r_spi_ss_n0;
end


always @(*) begin
    
    r_spi_ss_n0  = w_spi_ss_n0 ;
    r_spi_mosi   = w_spi_mosi  ;
end



always @(*) begin
    
    r_tx_done = w_tx_done;
end




// Instruction logic

reg [3:0]  r_read_step;  // 增加位宽以支持更多状态
reg [7:0]  r_instruction_bytes[2:0];


always @(posedge sys_clk) begin

    if(~rst_n) begin

        r_instruction <= 'd0;
        r_start <= 'd0;
        r_bram_addrb <= 12'h000;
        r_bram_enb <= 1'b0;
        r_read_step <= 4'd0;
        r_instruction_bytes[0] <= 8'h00;
        r_instruction_bytes[1] <= 8'h00;
        r_instruction_bytes[2] <= 8'h00;
    end

    else begin

        
        // When w_tx_done goes high, data transmission is complete, start reading instruction
        if(~r_tx_done) begin

            r_read_step <= 4'd0;
            r_start <= 1'b0;

            // r_test_led <= 'd0;
        end

        else if(w_tx_done) begin


            // r_test_led <= 'd1;

            // Read 3 bytes from BRAM sequentially with proper timing
            case(r_read_step)

                4'd0: begin // Start reading mode byte
                    r_bram_enb <= 1'b1;
                    r_bram_addrb <= 12'h000; // Mode byte address
                    r_read_step <= 4'd2;
                end

                // 4'd1: begin // Wait for BRAM output to stabilize
                //     r_read_step <= 4'd2;
                // end
                4'd2: begin // Read mode byte, setup row address
                    r_instruction_bytes[0] <= w_bram_doutb;

                    // if(w_bram_doutb == 8'h01) begin
                        
                    //     r_test_led <= 'd1;
                    // end

                    // else begin
                        
                    //     r_test_led <= 'd0;
                    // end


                    r_bram_addrb <= 12'h001; // Row byte address
                    r_read_step <= 4'd3;
                end
                4'd3: begin // Wait for BRAM output to stabilize
                    r_read_step <= 4'd4;
                end
                4'd4: begin // Read row byte, setup column address
                    r_instruction_bytes[1] <= w_bram_doutb;
                    r_bram_addrb <= 12'h002; // Column byte address
                    r_read_step <= 4'd5;
                end
                4'd5: begin // Wait for BRAM output to stabilize
                    r_read_step <= 4'd6;
                end
                4'd6: begin // Wait one more cycle for address 002
                    r_read_step <= 4'd7;
                end
                4'd7: begin // Read column byte
                    r_instruction_bytes[2] <= w_bram_doutb;
                    r_bram_enb <= 1'b0;
                    r_read_step <= 4'd8;
                end
                4'd8: begin // Assemble instruction
                    r_instruction <= {r_instruction_bytes[0], r_instruction_bytes[1], r_instruction_bytes[2]};
                    r_read_step <= 4'd9;
                end
                4'd9: begin // Start LED matrix
                    r_start <= 1'b1;
                    r_read_step <= 4'd10;
                end
                4'd10: begin // Hold start signal
                    r_start <= 1'b0;
                end
                default: begin // Hold start signal
                    r_start <= 1'b0;
                end
            endcase
        end

        else begin
            
            // w_tx_done is low, reset
            r_start <= 1'b0;
            r_bram_enb <= 1'b0;
            r_read_step <= 4'd0;
        end
    end
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
    
    r_write_addr <= 12'h000;
    
    // Initialize cross-clock signals
    r_write_req_sync <= 3'b000;
    r_write_req_edge <= 1'b0;
    r_write_data <= 8'h00;
    
    // Initialize instruction logic registers
    r_bram_enb  <= 'd0;
    r_bram_addrb<= 'd0;
    r_start     <= 'd0;
    r_instruction<= 'd0;
    r_tx_done <= 1'b0;
    r_read_step <= 4'd0;
    r_instruction_bytes[0] <= 8'h00;
    r_instruction_bytes[1] <= 8'h00;
    r_instruction_bytes[2] <= 8'h00;

end






// Master output slave input - receiver logic

always @(posedge spi_clk) begin
    
    if(~rst_n) begin
        
        r_data_mosi <= 'd0;
        r_mosi_cnt  <= 'd0;
    end 

    else begin

        if(FLAG_SEL) begin

            if(r_mosi_cnt == DATA_WIDTH - 1) begin

                r_mosi_cnt <= 'd0;
            end

            else begin

                r_data_mosi[DATA_WIDTH-1-r_mosi_cnt] <= r_spi_mosi;
                r_mosi_cnt <= r_mosi_cnt + 1'b1;
            end
        end

        else begin

            r_mosi_cnt <= 'd0;
        end

    end
end




// always @(posedge sys_clk) begin
    

//     if(r_bram_dina == 8'h01) begin

//         r_test_led <= 'd1;
//     end

//     else begin
        
//         r_test_led <= 'd0;
//     end
// end



// Master input slave output - sender logic

always @(posedge spi_clk) begin
    
    if(FLAG_SEL) begin
        
        r_spi_miso <= r_data_miso[r_miso_cnt]; 
        r_miso_cnt <= r_miso_cnt + 'd1;


        if(r_miso_cnt >= DATA_WIDTH) begin
            
            r_miso_cnt <= 'd0; 
        end
    end

    else begin
        
        r_miso_cnt <= 'd0;
    end
end


reg     r_write_delay;


// Cross-clock synchronization and edge detection
always @(posedge sys_clk) begin
    
    if(~rst_n) begin
        r_write_req_sync <= 3'b000;
        r_write_req_edge <= 1'b0;
    end
    
    else begin
        // 3-stage synchronizer for r_mosi_cnt final bit detection
        r_write_req_sync <= {r_write_req_sync[1:0], (r_mosi_cnt == DATA_WIDTH - 1)};
        
        // Edge detection - detect rising edge of final bit reception
        r_write_req_edge <= r_write_req_sync[1] & ~r_write_req_sync[2];
    end
end


// BRAM write logic using sys_clk domain with edge detection
always @(posedge sys_clk) begin
    
    if(~rst_n) begin
        r_write_addr <= 12'h000;
        r_bram_ena  <= 1'b0;
        r_bram_wea  <= 1'b0;
        r_bram_addra <= 12'h000;
        r_bram_dina <= 8'h00;
        r_write_data <= 8'h00;
    end

    else begin

        // Detect write request edge - when SPI byte reception completes
        if(r_write_req_edge) begin

            // Data encapsulation in BRAM logic - combine received data
            r_write_data <= {r_data_mosi[DATA_WIDTH-1:1], r_spi_mosi};

            // Execute BRAM write with encapsulated data
            r_bram_ena  <= 1'b1;
            r_bram_wea  <= 1'b1;
            r_bram_addra <= r_write_addr;
            r_bram_dina <= {r_data_mosi[DATA_WIDTH-1:1], r_spi_mosi}; // Data encapsulation here


            if(r_write_addr <= 12'hFFF) begin
                
                r_write_addr <= r_write_addr + 1'b1; 
            end

            else begin
                
                r_write_addr <= 12'h000; 
            end


            if(r_bram_dina == 8'h01) begin
                
                r_test_led <= 'd1;
            end

            else begin
                
                r_test_led <= 'd0;
            end


        end

        else begin
            // Clear write signals when no edge detected
            r_bram_ena <= 1'b0;
            r_bram_wea <= 1'b0;
        end
    end
end



endmodule

