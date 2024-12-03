`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////
// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for one clock cycle.
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
module uart_rx #(parameter CLKS_PER_BIT = 870) // Parameter to define clocks per bit
(
    input        i_Clock,          // Input clock signal
    input        i_Rx_Serial,      // Input serial data stream
    output       o_Rx_DV,          // Output signal indicating valid data
    output [7:0] o_Rx_Byte,         // Output 8-bit parallel data
    output reg data_in_debug
);

    // State encoding for the state machine
    parameter s_IDLE = 3'b000;         // Waiting for start bit
    parameter s_RX_START_BIT = 3'b001; // Receiving start bit
    parameter s_RX_DATA_BITS = 3'b010; // Receiving 8 data bits
    parameter s_RX_STOP_BIT = 3'b011;  // Receiving stop bit

    // Registers to hold state and data
    reg [2:0] r_SM_Main = 0;          // State machine register
    reg [7:0] r_Clock_Count = 0;      // Clock counter for timing bit sampling
    reg [2:0] r_Bit_Index = 0;        // Tracks which bit is being received
    reg [7:0] r_Rx_Byte = 0;          // Holds the received byte
    reg r_Rx_DV = 0;                  // Data valid flag, if using parity bit
   
    // Always block triggered on the rising edge of the clock
    always @(posedge i_Clock) begin
        // State machine for UART reception
        case (r_SM_Main)
            // IDLE State: Wait for the start bit (i_Rx_Serial goes low)
            s_IDLE: begin
                data_in_debug = 0;
                r_Rx_DV <= 1'b0; // Reset data valid flag
                if (i_Rx_Serial == 1'b0) begin // Start bit detected
                    r_SM_Main <= s_RX_START_BIT; // Move to the start bit state
                end
            end

            // RX_START_BIT State: Confirm the start bit
            s_RX_START_BIT: begin
            data_in_debug = 1;
                if (r_Clock_Count == (CLKS_PER_BIT - 1) / 2) begin
                    // Sample in the middle of the bit period
                    if (i_Rx_Serial == 1'b0) begin
                        // If start bit is still low, move to receive data
                        r_SM_Main <= s_RX_DATA_BITS;
                        r_Clock_Count <= 0; // Reset clock count
                    end else begin
                        // If start bit is not low, return to IDLE
                        r_SM_Main <= s_IDLE;
                    end
                end else begin
                    // Increment clock counter until the middle of the bit period
                    r_Clock_Count <= r_Clock_Count + 1;
                end
            end

            // RX_DATA_BITS State: Receive 8 data bits
            s_RX_DATA_BITS: begin
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    // Increment clock counter to wait for the next bit period
                    r_Clock_Count <= r_Clock_Count + 1;
                end else begin
                    // Reset clock counter and sample the bit
                    r_Clock_Count <= 0;
                    r_Rx_Byte[r_Bit_Index] <= i_Rx_Serial; // Store the bit
                    //$display("uart_rx.v: received %h", i_Rx_Serial);
                        
                    if (r_Bit_Index < 7) begin
                        // Move to the next bit
                        r_Bit_Index <= r_Bit_Index + 1;
                    end else begin
                        // If all 8 bits are received, move to the stop bit state
                        r_SM_Main <= s_RX_STOP_BIT;
                        r_Bit_Index <= 0; // Reset bit index
                    end
                end
            end

            // RX_STOP_BIT State: Confirm the stop bit
            s_RX_STOP_BIT: begin
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    // Wait for the stop bit period to complete
                    r_Clock_Count <= r_Clock_Count + 1;
                end else begin
                    // Stop bit should be high; signal valid data
                    r_Rx_DV <= 1'b1; // Indicate data is valid
                    r_SM_Main <= s_IDLE; // Return to IDLE state
                end
            end

        endcase
    end

    // Assign outputs
    assign o_Rx_Byte = r_Rx_Byte; // Parallel byte output
    assign o_Rx_DV = r_Rx_DV;     // Data valid signal output

endmodule
