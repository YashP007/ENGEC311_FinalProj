`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Class: ENGEC311: Final Project
//// Group - 6 Digital Filtering Using HDL
//// Finalized Date: 12/09/24
//// Author: Yash Patel
////////////////////////////////////////////////////////////////////////////////////
module main_automated
    #(
        parameter DBITS = 8,     // number of data bits in a word
        parameter SB_TICK = 16,  // number of stop bit / oversampling ticks
        parameter BR_LIMIT = 651,// baud rate generator counter limit
        parameter BR_BITS = 10,  // number of baud rate generator counter bits
        parameter FIFO_EXP = 8   // exponent for number of FIFO addresses
    )
    (
        input  clk_100MHz,       // FPGA clock
        input  reset_btn,        // active-high reset
        input  rx,               // serial data in
        output tx,               // serial data out
        
        output wire [DBITS-1:0] read_data, // Data read from RX FIFO
        
        output rx_full,          // indicates RX FIFO is full
        output rx_empty,         // indicates RX FIFO is empty
        output reg signal_debugging, // simple debug signal
        
        output reg read_flag,   // Flag to trigger reading from RX FIFO
        output reg write_flag,  // Flag to trigger writing to TX FIFO
        
        output wire rx_done_tick,    // a word received from UART RX module
        output wire tx_done_tick     // data transmission complete from UART TX module
    );

    // Internal signals
    //wire [DBITS-1:0] read_data;    // Data read from RX FIFO
    reg  [DBITS-1:0] data_reg;     // register to hold processed data
    reg  [DBITS-1:0] write_data_reg; // Data to write to TX FIFO

    //reg read_flag;   // Flag to trigger reading from RX FIFO
    //reg write_flag;  // Flag to trigger writing to TX FIFO

    // Simple State Machine for Automatic Data Flow
    localparam IDLE       = 2'b00;
    localparam READ_WAIT  = 2'b01; 
    localparam WRITE_WAIT = 2'b10; 

    reg [1:0] state, next_state;

    // State Register
    always @(posedge clk_100MHz or posedge reset_btn) begin
        if (reset_btn)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next State Logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                // If there is data in the RX FIFO, move to READ_WAIT to fetch it
                if (~rx_empty)
                    next_state = READ_WAIT;
                else
                    next_state = IDLE;
            end

            READ_WAIT: begin
                // After asserting read_flag, next cycle data_reg will hold the read data
                // Then we proceed to WRITE_WAIT to write the data out
                next_state = WRITE_WAIT;
            end

            WRITE_WAIT: begin
                // After writing data to TX FIFO, return to IDLE to check for more data
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // Output and Control Logic
    always @(posedge clk_100MHz or posedge reset_btn) begin
        if (reset_btn) begin
            read_flag <= 0;
            write_flag <= 0;
            data_reg <= 0;
            write_data_reg <= 0;
        end else begin
            // Default signals
            read_flag <= 0;
            write_flag <= 0;

            case (state)
                IDLE: begin
                    // Check if data is available in RX FIFO
                    // If yes, trigger one read
                    if (~rx_empty) begin
                        read_flag <= 1;
                    end
                end

                READ_WAIT: begin
                    // We just read data, now store it in data_reg
                    // You can modify this line to process data before sending it back
                    data_reg <= read_data;
                end

                WRITE_WAIT: begin
                    // Write the processed data back to the TX FIFO
                    write_data_reg <= data_reg;
                    write_flag <= 1;
                end
            endcase
        end
    end

    // For debugging: signal_debugging = not empty => indicates data presence
    always @(*) begin
        signal_debugging = ~rx_empty;
    end

    // Instantiate UART Top Module
    uart_top 
        #(
            .DBITS(DBITS),
            .SB_TICK(SB_TICK),
            .BR_LIMIT(BR_LIMIT),
            .BR_BITS(BR_BITS),
            .FIFO_EXP(FIFO_EXP)
        ) 
    UART_SYS
        (
            .clk_100MHz(clk_100MHz),
            .reset_btn(reset_btn),
            .read_uart_btn(read_flag),    // Automatically triggered read
            .write_uart_btn(write_flag),  // Automatically triggered write
            .rx(rx),
            .rx_done_tick(rx_done_tick),
            .rx_full(rx_full),
            .rx_empty(rx_empty),
            .tx(tx),
            .signal_debugging(), // unused here
            .read_data(read_data),
            .write_data(write_data_reg),
            .tx_done_tick(tx_done_tick)
        );

endmodule
