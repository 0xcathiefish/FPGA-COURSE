// Version 1.0

/*
Simple BRAM test - write 8'h01 and read it back
*/

`timescale 1ns / 1ps

module bram_tb();

    // Parameters
    parameter CLK_PERIOD = 10; // 100MHz system clock

    // System signals
    reg clk;
    reg rst_n;
    
    // BRAM write control signals (Port A)
    reg [11:0] r_bram_addra;
    reg [7:0] r_bram_dina;
    reg r_bram_ena;
    reg r_bram_wea;
    
    // BRAM read control signals (Port B)
    reg r_bram_enb;
    reg [11:0] r_bram_addrb;
    wire [7:0] w_bram_doutb;

    // BRAM instance
    spi_bram spi_bram_0 (
        .clka(clk),
        .ena(r_bram_ena),
        .wea(r_bram_wea),
        .addra(r_bram_addra),
        .dina(r_bram_dina),
        
        .clkb(clk),
        .enb(r_bram_enb),
        .addrb(r_bram_addrb),
        .doutb(w_bram_doutb)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Main test sequence
    initial begin
        $display("=== Simple BRAM Test Start ===");
        
        // Initialize signals
        rst_n = 1'b1;
        r_bram_addra = 12'h000;
        r_bram_dina = 8'h00;
        r_bram_ena = 1'b0;
        r_bram_wea = 1'b0;
        r_bram_enb = 1'b0;
        r_bram_addrb = 12'h000;
        
        // Reset
        rst_n = 1'b0;
        repeat(5) @(posedge clk);
        rst_n = 1'b1;
        repeat(2) @(posedge clk);
        
        // Write 8'h01 to address 0x000
        $display("Writing 8'h01 to address 0x000...");
        @(posedge clk);
        r_bram_ena <= 1'b1;
        r_bram_wea <= 1'b1;
        r_bram_addra <= 12'h000;
        r_bram_dina <= 8'h01;
        @(posedge clk);
        r_bram_ena <= 1'b0;
        r_bram_wea <= 1'b0;
        $display("Write complete");
        
        // Wait a few cycles
        repeat(3) @(posedge clk);
        
        // Read from address 0x000
        $display("Reading from address 0x000...");
        @(posedge clk);
        r_bram_enb <= 1'b1;
        r_bram_addrb <= 12'h000;
        @(posedge clk);
        
        // Check result
        $display("Read data: 0x%02h", w_bram_doutb);
        if(w_bram_doutb == 8'h01) begin
            $display("✓ SUCCESS: Correctly read 8'h01");
        end else begin
            $display("✗ FAILED: Expected 8'h01, got 8'h%02h", w_bram_doutb);
        end
        
        r_bram_enb <= 1'b0;


        #100;
        
        $display("=== Test Complete ===");
        $finish;
    end

endmodule