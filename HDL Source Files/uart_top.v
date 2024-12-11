`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Class: ENGEC311: Final Project
//// Group - 6 Digital Filtering Using HDL
//// Finalized Date: 12/09/24
//// Author: Yash Patel
//////////////////////////////////////////////////////////////////////////////////////
// Top Module for the Complete UART System
//
// Setup for 9600 Baud Rate
//
// For 9600 baud with 100MHz FPGA clock: 
// 9600 * 16 = 153,600
// 100 * 10^6 / 153,600 = ~651      (counter limit M)
// log2(651) = 10                   (counter bits N) 
//
// For 19,200 baud rate with a 100MHz FPGA clock signal:
// 19,200 * 16 = 307,200
// 100 * 10^6 / 307,200 = ~326      (counter limit M)
// log2(326) = 9                    (counter bits N)
//
// For 115,200 baud with 100MHz FPGA clock:
// 115,200 * 16 = 1,843,200
// 100 * 10^6 / 1,843,200 = ~52     (counter limit M)
// log2(52) = 6                     (counter bits N) 
//
// For 1500 baud with 100MHz FPGA clock:
// 1500 * 16 = 24,000
// 100 * 10^6 / 24,000 = ~4,167     (counter limit M)
// log2(4167) = 13                  (counter bits N) 
//
// Comments:
// - Many of the variable names have been changed for clarity
//////////////////////////////////////////////////////////////////////////////////

module uart_top
    #(
        parameter   DBITS = 8,          // number of data bits in a word
                    SB_TICK = 16,       // number of stop bit / oversampling ticks
                    BR_LIMIT = 651,     // baud rate generator counter limit
                    BR_BITS = 10,       // number of baud rate generator counter bits
                    FIFO_EXP = 8        // exponent for number of FIFO addresses (2^2 = 4)
    )
    (
        input clk_100MHz,               // FPGA clock
        input reset_btn,                    // reset
        input read_uart_btn,                // button, will read in data from buffer when sent to high and push one into buffer thus one out of buffer as well
        input write_uart_btn,               // button, will sent data back out when set to high and 
        input rx,                       // serial data in
        input [DBITS-1:0] write_data,   // data from Tx FIFO  
        output wire rx_done_tick,       // data word recieved to uart rx module
        output rx_full,                 // do not write data to FIFO
        output rx_empty,                // no data to read from FIFO
        output tx,                      // serial data out
        output wire signal_debugging, // for debugging only
        output [DBITS-1:0] read_data,    // data to Rx FIFO
        output wire tx_done_tick                  // data transmission complete
    );
    
    // Connection Signals
    wire tick;                          // sample tick from baud rate generator
    wire tx_empty;                      // Tx FIFO has no data to transmit
    wire tx_fifo_not_empty;             // Tx FIFO contains data to transmit
    wire [DBITS-1:0] tx_fifo_out;       // from Tx FIFO to UART transmitter
    wire [DBITS-1:0] rx_data_out;       // from UART receiver to Rx FIFO
    
    wire reset, read_uart, write_uart; // debounced button variables
    
    //what signal to debug and send out? 
    assign signal_debugging = reset;
    
    // define all debounced signals
    
    // reset button
    debounce_explicit resetbtn(
        .clk_100MHz(clk_100MHz),
        .reset(),
        .btn(reset_btn),              // button input
        .db_level(),    // for switches
        .db_tick(reset)      // for buttons
    );
    
    // reset button
    debounce_explicit rxbtn(
        .clk_100MHz(clk_100MHz),
        .reset(),
        .btn(read_uart_btn),              // button input
        .db_level(),    // for switches
        .db_tick(read_uart)      // for buttons
    );
    
    // reset button
    debounce_explicit txbtn(
        .clk_100MHz(clk_100MHz),
        .reset(),
        .btn(write_uart_btn),              // button input
        .db_level(),    // for switches
        .db_tick(write_uart)      // for buttons
    );
    
    // Instantiate Modules for UART Core
    baud_rate_generator 
        #(
            .M(BR_LIMIT), 
            .N(BR_BITS)
         ) 
        BAUD_RATE_GEN   
        (
            .clk_100MHz(clk_100MHz), 
            .reset(reset),
            .tick(tick)
         );
    
    uart_receiver
        #(
            .DBITS(DBITS),
            .SB_TICK(SB_TICK)
         )
         UART_RX_UNIT
         (
            .clk_100MHz(clk_100MHz),
            .reset(reset),
            .rx(rx),
            .sample_tick(tick),
            .data_ready(rx_done_tick),
            .data_out(rx_data_out)
         );
    
    uart_transmitter
        #(
            .DBITS(DBITS),
            .SB_TICK(SB_TICK)
         )
         UART_TX_UNIT
         (
            .clk_100MHz(clk_100MHz),
            .reset(reset),
            .tx_start(tx_fifo_not_empty),
            .sample_tick(tick),
            .data_in(tx_fifo_out),
            .tx_done(tx_done_tick),
            .tx(tx)
         );
    
    fifo
        #(
            .DATA_SIZE(DBITS),
            .ADDR_SPACE_EXP(FIFO_EXP)
         )
         FIFO_RX_UNIT
         (
            .clk(clk_100MHz),
            .reset(reset),
            .write_to_fifo(rx_done_tick),
	        .read_from_fifo(read_uart),
	        .write_data_in(rx_data_out),
	        .read_data_out(read_data),
	        .empty(rx_empty),
	        .full(rx_full)            
	      );
	   
    fifo
        #(
            .DATA_SIZE(DBITS),
            .ADDR_SPACE_EXP(FIFO_EXP)
         )
         FIFO_TX_UNIT
         (
            .clk(clk_100MHz),
            .reset(reset),
            .write_to_fifo(write_uart),
	        .read_from_fifo(tx_done_tick),
	        .write_data_in(write_data), // if you want your data to come from somewhere else. 
	        .read_data_out(tx_fifo_out),
	        .empty(tx_empty),
	        .full()                // intentionally disconnected
	      );
    
    // Signal Logic
    assign tx_fifo_not_empty = ~tx_empty;
  
endmodule
