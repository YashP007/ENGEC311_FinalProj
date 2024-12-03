`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// This file contains the UART Transmitter.  This transmitter is able
// to transmit 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When transmit is complete o_Tx_done will be
// driven high for one clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
module uart_tx #(parameter CLKS_PER_BIT = 870)
(
    input        i_Clock,
    input        i_Tx_DV,
    input [7:0]  i_Tx_Byte,
    output       o_Tx_Active,
    output reg   o_Tx_Serial,
    output       o_Tx_Done
);
    parameter s_IDLE = 3'b000;
    parameter s_TX_START_BIT = 3'b001;
    parameter s_TX_DATA_BITS = 3'b010;
    parameter s_TX_STOP_BIT = 3'b011;
    parameter s_CLEANUP = 3'b100;

    reg [2:0] r_SM_Main = 0;
    reg [7:0] r_Clock_Count = 0;
    reg [2:0] r_Bit_Index = 0;
    reg [7:0] r_Tx_Data = 0;
    reg r_Tx_Active = 0;
    reg r_Tx_Done = 0;

    always @(posedge i_Clock) begin
        case (r_SM_Main)
            s_IDLE: begin
                o_Tx_Serial <= 1'b1; // Line idle
                r_Tx_Done <= 1'b0;
                r_Bit_Index <= 0;
                if (i_Tx_DV) begin
                    r_Tx_Active <= 1'b1;
                    r_Tx_Data <= i_Tx_Byte;
                    r_SM_Main <= s_TX_START_BIT;
                end else begin
                    r_SM_Main <= s_IDLE;
                end
            end

            s_TX_START_BIT: begin
                o_Tx_Serial <= 1'b0; // Start bit
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    r_Clock_Count <= r_Clock_Count + 1;
                end else begin
                    r_Clock_Count <= 0;
                    r_SM_Main <= s_TX_DATA_BITS;
                end
            end

            s_TX_DATA_BITS: begin
                o_Tx_Serial <= r_Tx_Data[r_Bit_Index];
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    r_Clock_Count <= r_Clock_Count + 1;
                end else begin
                    r_Clock_Count <= 0;
                    if (r_Bit_Index < 7) begin
                        r_Bit_Index <= r_Bit_Index + 1;
                    end else begin
                        r_Bit_Index <= 0;
                        r_SM_Main <= s_TX_STOP_BIT;
                    end
                end
            end

            s_TX_STOP_BIT: begin
                o_Tx_Serial <= 1'b1; // Stop bit
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    r_Clock_Count <= r_Clock_Count + 1;
                end else begin
                    r_Clock_Count <= 0;
                    r_SM_Main <= s_CLEANUP;
                end
            end

            s_CLEANUP: begin
                r_Tx_Done <= 1'b1;
                r_Tx_Active <= 1'b0;
                r_SM_Main <= s_IDLE;
            end
        endcase
    end

    assign o_Tx_Active = r_Tx_Active;
    assign o_Tx_Done = r_Tx_Done;
endmodule
