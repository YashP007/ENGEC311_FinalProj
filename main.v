`timescale 1ns / 1ps

module main (
    input wire        clk,               // System clock
    input wire        uart_rx,           // UART RX (Serial input)
    output wire       uart_tx,           // UART TX (Serial output)
    output wire [7:0] data_out,          // Processed data to be sent back (for example to a testbench or another system)
    output wire data_in_debug
);
    // Centralized baud rate calculation
    parameter CLK_FREQ = 100000000;  // 10 MHz clock frequency (example)
    parameter BAUD_RATE = 115200;   // Desired baud rate for UART communication
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;  // Number of clock cycles per bit

    // Wires for UART communication
    wire uart_rx_dv;      // UART receive data valid
    wire [7:0] uart_rx_byte;  // Received byte from UART
    wire uart_tx_done;    // UART transmit done flag
    reg uart_tx_dv;       // UART transmit data valid
    reg [7:0] uart_tx_byte; // Data to be transmitted via UART
    
    // Instantiate the UART Receiver module
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_rx_inst (
        .i_Clock(clk),
        .i_Rx_Serial(uart_rx),
        .o_Rx_DV(uart_rx_dv),
        .o_Rx_Byte(uart_rx_byte),
        .data_in_debug(data_in_debug)
    );

    // Instantiate the FIR filter module
    fir_filter fir_filter_inst (
        .clk(clk),
        .data_in(uart_rx_byte),
        .data_out(data_out)  // Processed data out of the FIR filter
    );

    // Instantiate the UART Transmitter module
    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_tx_inst (
        .i_Clock(clk),
        .i_Tx_DV(uart_tx_dv),
        .i_Tx_Byte(uart_tx_byte),
        .o_Tx_Active(),
        .o_Tx_Serial(uart_tx),
        .o_Tx_Done(uart_tx_done)
    );

    // Handle UART communication flow (full-duplex operation)
    always @(posedge clk) begin
        // On receiving valid data, process it and send the response back
        if (uart_rx_dv) begin
            // Process the received byte through the FIR filter
            uart_tx_byte <= data_out;  // Send the processed data
            uart_tx_dv <= 1'b1;         // Enable transmit data valid
        end else if (uart_tx_done) begin
            uart_tx_dv <= 1'b0;         // Disable transmit data valid once transmission is done
        end
    end

endmodule
