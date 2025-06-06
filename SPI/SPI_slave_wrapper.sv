// Version 1.0

/*

*/

`include "./SPI_defines.vh"

module spi_slave_wrapper #(

    // SPI Data
    parameter DATA_WIDTH                    = 8                                                     ,                                            


    // LED Matrix
    parameter integer p_frequency           = 50_000_000                                            ,   // System clk frequency
    parameter integer p_pwm_bits            = 8                                                     ,   // PWM resolution bits
    parameter integer p_row_num             = 8                                                     ,   // Matrix row num  
    parameter integer p_column_num          = 8                                                     ,   // Matrix column num
    parameter integer p_control_num         = 3                                                     ,   // Controlling pin num for each led
    parameter integer p_brightness_step_ms  = 10                                                    ,   // Each brightness level duration in ms

    parameter integer p_DELAY_05MS_CYCLE   = p_frequency / 500                                     
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

reg     [$clog2(DATA_WIDTH) - 1: 0] r_mosi_cnt                                                      ;
reg     [$clog2(DATA_WIDTH) - 1: 0] r_miso_cnt                                                      ;


// Memory array to replace BRAM (4K x 8bit)
reg     [7:0]                       memory_array [0:4095]                                           ;
reg     [11:0]                      r_write_addr                                                    ;
reg     [11:0]                      r_read_addr                                                     ;

// Tx reg
reg                                 r_tx_done                                                       ;

// LED matrix                                               
reg                                 r_start                                                         ;
reg     [8 + p_row_num + p_column_num - 1 : 0]  r_instruction                                       ;
reg     [7:0]                                   r_instruction_bytes     [2:0]                       ;

// FLAG
reg                                 FLAG_SEL                                                        ;

// Test LED
reg                                 r_test_led                                                      ;

// Instruction State Machine
reg     [3 : 0]                     STATE_INS                                                       ;



reg     [$clog2(p_DELAY_05MS_CYCLE) - 1 : 0] r_delay_count                                          ;



/*--------------------------------register-------------------------------------------*/



/*--------------------------------wire-----------------------------------------------*/

// LED matrix           
wire    [p_row_num - 1 : 0]         w_row_anode_intermit                                            ; 
wire    [p_control_num - 1 : 0]     w_column_cell_intermit  [0 : p_column_num - 1]                  ;


/*--------------------------------wire-----------------------------------------------*/






/*--------------------------------assign---------------------------------------------*/

// SPI interface
assign   w_spi_miso                 = r_spi_miso                                                    ;   

// LED Matrix               
assign   w_row_anode                = w_row_anode_intermit                                          ;
assign   w_column_cell              = w_column_cell_intermit                                        ;

// Test LED
assign   w_test_led                 = r_test_led                                                    ;

/*--------------------------------assign---------------------------------------------*/


LED_Matrix #(

    .p_frequency                    (p_frequency            )                                       ,
    .p_pwm_bits                     (p_pwm_bits             )                                       ,
    .p_row_num                      (p_row_num              )                                       ,
    .p_column_num                   (p_column_num           )                                       ,
    .p_control_num                  (p_control_num          )                                       ,
    .p_brightness_step_ms           (p_brightness_step_ms   )


) led_matrix_uut

(

    .clk                            (sys_clk                )                                       ,               
    .rst_n                          (rst_n                  )                                       ,
    .start                          (r_start                )                                       ,

    .w_instruction                  (r_instruction          )                                       ,
    .w_row_anode                    (w_row_anode_intermit   )                                       ,
    .w_column_cell                  (w_column_cell_intermit )         

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


always @(posedge sys_clk) begin

    if(~rst_n) begin

        r_instruction           <= 'd0;
        r_start                 <= 'd0;
        r_read_addr             <= 12'h000;
        STATE_INS               <= 4'd0;
        r_instruction_bytes[0]  <= 8'h00;
        r_instruction_bytes[1]  <= 8'h00;
        r_instruction_bytes[2]  <= 8'h00;
        r_delay_count           <= 'd0  ;



        // for(integer i=0; i<4096; i=i+1) begin
            
        //     memory_array [i] <= 8'h00; 
        // end
        
    end

    else begin

        // When w_tx_done goes high, data transmission is complete, start reading instruction
        if(~r_tx_done) begin

            STATE_INS <= 4'd0;
            r_start <= 1'b0;
            r_read_addr <= 12'h000;
        end

        else begin

            // Read 3 bytes from memory array sequentially
            case(STATE_INS)

                `ST_INS_IDLE: begin
                    
                    if(r_tx_done) begin
                        
                        STATE_INS <= `ST_INS_FETCH;
                    end
                end


                `ST_INS_FETCH: begin // Read mode byte 

                    r_instruction_bytes[0] <= memory_array[r_read_addr + 'd0];
                    r_instruction_bytes[1] <= memory_array[r_read_addr + 'd1];
                    r_instruction_bytes[2] <= memory_array[r_read_addr + 'd2];

                    
                    // if(memory_array[12'h000] == 8'h01) begin
                        
                    //     r_test_led <= 'd1;
                    // end

                    // else begin
                        
                    //     r_test_led <= 'd0;
                    // end


                    STATE_INS <= `ST_INS_ASSEMBLE;
                end
                
                
                `ST_INS_ASSEMBLE: begin // Assemble instruction

                    r_instruction <= {r_instruction_bytes[0], r_instruction_bytes[1], r_instruction_bytes[2]};
                    STATE_INS <= `ST_INS_EXCUTE;
                end
                

                `ST_INS_EXCUTE: begin // Start LED matrix

                    r_start <= 1'b1;

                    case(r_instruction[23:22])


                        2'b00, 2'b01: begin // Basic mode
                            
                            STATE_INS <= `ST_INS_DONE;
                            

                            if(r_read_addr + 'd3 <= 12'hFFF) begin

                                r_read_addr <= r_read_addr + 'd3;
                            end

                            else begin
                        
                                r_read_addr <= 12'h000; 
                            end
                        end


                        2'b11: begin // animation mode
                            

                            if(r_delay_count <= p_DELAY_05MS_CYCLE - 1) begin

                                r_delay_count <= r_delay_count + 'd1;

                                STATE_INS <= `ST_INS_EXCUTE;

                            end

                            else if(r_delay_count >= p_DELAY_05MS_CYCLE) begin

                                r_delay_count <= 'd0;

                                STATE_INS <= `ST_INS_FETCH;


                                if(r_read_addr + 'd3 <= 12'd4077) begin

                                    r_read_addr <= r_read_addr + 'd3;
                                end

                                else begin
                                
                                    r_read_addr <= 12'h000; 
                                end
                            end
                        end


                        2'b10: begin // pic mode
                            

                            if(r_delay_count <= p_DELAY_05MS_CYCLE - 1) begin

                                r_delay_count <= r_delay_count + 'd1;

                                STATE_INS <= `ST_INS_EXCUTE;

                            end

                            else if(r_delay_count >= p_DELAY_05MS_CYCLE) begin

                                r_delay_count <= 'd0;

                                STATE_INS <= `ST_INS_FETCH;


                                if(r_read_addr + 'd3 <= 12'd21) begin

                                    r_read_addr <= r_read_addr + 'd3;
                                end

                                else begin
                                
                                    r_read_addr <= 12'h000; 
                                end
                            end
                        end


                    endcase

                end


                `ST_INS_DONE: begin
                    

                end
                
                
                default: begin // Hold start signal

                    r_start <= 1'b0;
                end

            endcase
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
    
    // Initialize instruction logic registers
    r_read_addr <= 12'h000;
    r_tx_done <= 1'b0;
    STATE_INS <= 4'd0;
    r_instruction_bytes[0] <= 8'h00;
    r_instruction_bytes[1] <= 8'h00;
    r_instruction_bytes[2] <= 8'h00;

end






// Master output slave input - receiver logic

always @(posedge spi_clk) begin
    
    if(~rst_n) begin
        
        r_data_mosi <= 'd0;
        r_mosi_cnt  <= 'd0;
        r_write_addr<= 12'h000;
    end 

    else begin

        if(FLAG_SEL) begin

            if(r_mosi_cnt == DATA_WIDTH - 1) begin

                r_mosi_cnt <= 'd0;

                memory_array[r_write_addr] <= {r_data_mosi[DATA_WIDTH-1:1], r_spi_mosi};

                if(r_write_addr <= 12'hFFF) begin

                    r_write_addr <= r_write_addr + 1'b1; 
                end

                else begin

                    r_write_addr <= 12'h000; 
                end

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


// Test LED
always @(posedge sys_clk) begin
    
    if(~rst_n) begin
        r_test_led <= 1'b0;
    end

    else begin

        // Test LED logic
        if(memory_array[12'h000] == 8'h02 && memory_array[12'h001] == 8'h03 && memory_array[12'h002] == 8'h03) begin

            r_test_led <= 1'b1;
        end

        else begin

            r_test_led <= 1'b0;
        end

    end
end


endmodule


