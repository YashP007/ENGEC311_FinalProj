`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
 
module uart_filter_tb;
    parameter CLKS_PER_BIT = 2; // 115200 baud rate for 10 MHz clock
    parameter BIT_PERIOD = 4; // In nanoseconds, for simulation timing
    parameter wait_per = 1; // BIT_PERIOD / CLKS_PER_BIT / 2 // use this equation to determine wait_per parameter which is 1/2 clk cycle

    // Clock generation
    reg clk = 0;
    always #wait_per clk = ~clk; // 10 MHz clock

    // Signals for UART transmitter and receiver
    reg tx_dv = 0;
    reg [7:0] tx_byte = 0;
    wire tx_done;
    wire tx_active;
    wire tx_serial;

    reg rx_serial = 1;
    wire [7:0] rx_byte;
    wire rx_dv;

    // FIR Filter
    wire [7:0] filtered_data;

    // Instantiate UART Transmitter
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_tx_inst (
        .i_Clock(clk),
        .i_Tx_DV(tx_dv),
        .i_Tx_Byte(tx_byte),
        .o_Tx_Active(tx_active),
        .o_Tx_Serial(tx_serial),
        .o_Tx_Done(tx_done)
    );

    // Instantiate UART Receiver
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_rx_inst (
        .i_Clock(clk),
        .i_Rx_Serial(rx_serial),
        .o_Rx_DV(rx_dv),
        .o_Rx_Byte(rx_byte)
    );

    // Instantiate FIR Filter
    fir_filter fir_filter_inst (
        .clk(clk),
        .data_in(rx_byte),
        .data_out(filtered_data)
    );

    // Task to write a byte into the UART transmitter
    task UART_WRITE_BYTE;
        input [7:0] data;
        integer i;
        begin
            // Send start bit
            rx_serial <= 1'b0;
            #(BIT_PERIOD);

            // Send 8-bit data
            for (i = 0; i < 8; i = i + 1) begin
                rx_serial <= data[i];
                //$display("uart_tb.b: sent %h", data[i]);
                #(BIT_PERIOD);
            end

            // Send stop bit
            rx_serial <= 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    initial begin
        // Test UART transmitter
        $display("Starting UART Transmitter Test...");
        tx_dv <= 1'b1; // sending start bit
        tx_byte <= 8'h55; // Example byte
        @(posedge clk);
        tx_dv <= 1'b0;
        wait(tx_done); // Wait for the transmission to complete
        $display("UART Transmitter Test Passed!");

        // Test UART receiver
        $display("Starting UART Receiver Test...");
        UART_WRITE_BYTE(8'hAA); // Send data to receiver
        wait(rx_dv); // Wait for the receiver to indicate data received
        if (rx_byte == 8'hAA) begin
            $display("UART Receiver Test Passed!");
        end else begin
            $display("UART Receiver Test Failed: Expected 8'hAA, Received %h", rx_byte);
        end

        // Test FIR filter
        $display("Starting FIR Filter Test...");
        UART_WRITE_BYTE(8'd100); // Input a sample to the filter
        wait(rx_dv); // Ensure the receiver gets the data
        @(posedge clk); // Allow filter to process the data
        $display("FIR Filter Output: %d", filtered_data);

        // Test end-to-end functionality
        $display("Starting End-to-End System Test...");
        tx_dv <= 1'b1;
        tx_byte <= 8'd50; // Input fixed-point value
        @(posedge clk);
        tx_dv <= 1'b0;
        wait(tx_done); // Wait for the transmitter to finish
        UART_WRITE_BYTE(tx_byte); // Send the data through UART
        wait(rx_dv); // Wait for receiver
        @(posedge clk); // Allow filter to process
        $display("End-to-End Test Filtered Output: %d", filtered_data);

        $finish;
    end
endmodule
