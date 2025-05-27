// Version 1.0

/*
This is the LED matrix controller module
Including Single led, row led, water led, PWM four mode

*/

module LED_Matrix#(

    parameter integer row_num       = 8     ,
    parameter integer column_num    = 8     ,
    parameter integer control_num   = 3     ,

    parameter integer LED_NUM       = row_num * column_num  

)

(
    input   wire    clk                                                                 ,
    input   wire    rst_n                                                               ,
    input   wire    start                                                               ,
    
    input   wire    [3 : 0]                     w_mode                                  ,

    output  wire    [row_num - 1 : 0]           w_row_anode                             ,
    output  wire    [control_num - 1 : 0]       w_column_cell     [0 : column_num - 1]  ,

    output  wire                                w_done                      
    
);



/*--------------------------------register-------------------------------------------*/

// Matrix output temp reg
reg     [row_num - 1 : 0]                       r_row_anode                             ;
reg     [control_num - 1 : 0]                   r_column_cell     [0 : column_num - 1]  ;
reg     [3 : 0]                                 r_mode                                  ;
reg                                             r_done                                  ;


// State Machine

typedef enum logic [3 : 0] { 

    ST_IDLE     ,
    ST_SL       ,
    ST_RL       ,
    ST_WL       ,
    ST_PWM      ,
    ST_DONE

} STATE;

STATE                                           CURRENT_STATE, NEXT_STATE               ;

reg                                             FLAG_Single_Light_Done                  ;
reg                                             FLAG_Row_Light_Done                     ;
reg                                             FLAG_Water_Light_Done                   ;
reg                                             FLAG_PWM_Done                           ;


// Water LED

reg     [$clog2(LED_NUM) - 1 : 0]               WL_count                                ;



/*--------------------------------register-------------------------------------------*/



/*--------------------------------wire-----------------------------------------------*/


/*--------------------------------wire-----------------------------------------------*/



/*--------------------------------assign---------------------------------------------*/

// Matrix output wire connect
assign  w_row_anode                             = r_row_anode                           ;
assign  w_column_cell                           = r_column_cell                         ;
assign  w_mode                                  = r_mode                                ;
assign  w_done                                  = r_done                                ;

/*--------------------------------assign---------------------------------------------*/


// Done logic

always @(posedge clk) begin
    
    if(~rst_n) begin
        
        r_done <= 'd0; 
    end

    else begin
        
        if(FLAG_Single_Light_Done || FLAG_Row_Light_Done || FLAG_Water_Light_Done || FLAG_PWM_Done) begin
            
            r_done <= 'd1;
        end

        else if(r_done == 'd1) begin
            
            r_done <= 'd0;
        end

        else begin
            
            r_done <= r_done; 
        end
    end

end



// State Machine


// State Machine Running logic

always @(posedge clk) begin
    
    if(~rst_n) begin
        
        CURRENT_STATE <= ST_IDLE; 
    end

    else begin
        
        CURRENT_STATE <= NEXT_STATE; 
    end
end



// State Machine Next State controller

always @(*) begin
    
    case(CURRENT_STATE)

        // IDLE
        ST_IDLE: NEXT_STATE = start ? ST_SL : ST_IDLE;


        // Single LED
        ST_SL: begin

            if(~FLAG_Single_Light_Done) begin

                NEXT_STATE = ST_SL; 
            end

            else if(FLAG_Single_Light_Done) begin

                NEXT_STATE = ST_DONE; 
            end
        end


        // Row LED
        ST_RL: begin

            if(~FLAG_Row_Light_Done) begin

                NEXT_STATE = ST_RL; 
            end

            else if(FLAG_Row_Light_Done) begin

                NEXT_STATE = ST_DONE; 
            end
        end


        // Water LED
        ST_WL: begin

            if(~FLAG_Water_Light_Done) begin

                NEXT_STATE = ST_WL; 
            end 

            else if(FLAG_Water_Light_Done) begin

                NEXT_STATE = ST_DONE; 
            end
        end


        // PWM
        ST_PWM: begin

            if(~FLAG_PWM_Done) begin

                NEXT_STATE = ST_PWM;
            end

            else if(FLAG_PWM_Done) begin

                NEXT_STATE = ST_DONE;
            end
        end

    endcase

end



// State Machine Definition

// Mode definition

`define     MODE_SL     'd1
`define     MODE_RL     'd2
`define     MODE_WL     'd3
`define     MODE_PWM    'd4


// Main Logic

always @(posedge clk) begin
    
    case(CURRENT_STATE)

        // IDLE: Doing nothing
        ST_IDLE: begin

        end


        // Turn on a Single Led
        ST_SL: begin

            if(~FLAG_Single_Light_Done) begin

                r_row_anode             <= 8'b0010_0000     ;
                r_column_cell[2]        <= 3'b011           ;
                FLAG_Single_Light_Done  <= 'd1              ;
            end

        end


        // Turn on all the led of a Row
        ST_RL: begin

            if(~FLAG_Row_Light_Done) begin
                
                r_row_anode             <= 8'b0100_0000     ;
                for(int i=0; i<=column_num; i++) begin
                    
                    r_column_cell[i]    <= 3'b110;
                end

                FLAG_Row_Light_Done     <= 'd1;
            end

        end


        // Water Light Mode
        ST_WL: begin

            if(~FLAG_Water_Light_Done && WL_count <= 7) begin

                r_column_cell[2]        <= 3'b101           ;
                r_row_anode             <= (WL_count == 0) ? 8'b0000_0001 : r_row_anode << 1;
                WL_count                <= WL_count + 1;
                
                if(WL_count == 7) begin

                    FLAG_Water_Light_Done <= 1'b1;
                end
            end

        end


        // PWM controller
        ST_PWM: begin

        end


        
        ST_DONE: begin
            
            FLAG_PWM_Done           <= 'd0  ;
            FLAG_Row_Light_Done     <= 'd0  ;
            FLAG_Single_Light_Done  <= 'd0  ;
            FLAG_Water_Light_Done   <= 'd0  ;

        end

    endcase

end


// MODE Controller

always @(*) begin
    
    case(r_mode)

        `MODE_SL: begin
            
            NEXT_STATE <= ST_SL; 
        end


    endcase

end


endmodule
