`timescale 1ns / 1ps
module main_autobtn
    #(
        parameter DBITS = 8,    // number of data bits in a word
        parameter SB_TICK = 16, // number of stop bit / oversampling ticks
        parameter BR_LIMIT = 651, // baud rate generator counter limit
        parameter BR_BITS = 10, // number of baud rate generator counter bits
        parameter FIFO_EXP = 8  // exponent for number of FIFO addresses
    )
    (
        input clk_100MHz,       // FPGA clock
        input reset_btn,        // reset

        // Debugging/Manual Control Buttons
        input input_switch,     // switch to controll when rx and tx are flipping

        input rx,               // serial data in
        output tx,              // serial data out

        output rx_full,         // indicates RX FIFO is full
        output rx_empty,        // indicates RX FIFO is empty
        output reg signal_debugging, // for debugging only

        output wire [DBITS-1:0] read_data, // Data that will be written to TX FIFO
        output reg write_flag,  // Flag to trigger writing to TX FIFO
        output reg read_flag,   // Flag to trigger reading from RX FIFO

        output wire rx_done_tick,  // data word received to uart rx module
        output wire tx_done_tick   // data transmission complete
    );

    // Internal Registers
    reg [DBITS-1:0] data_reg;       // register to hold processed data
    //wire [DBITS-1:0] read_data; // Data that will be written to TX FIFO
    wire [DBITS-1:0] y_data;    // the data coming out of the fir filter. :) 
    reg [DBITS-1:0] write_data_reg; //
    reg read_uart_btn;    // Button to trigger reading from RX FIFO
    reg write_uart_btn;   // Button to trigger writing to TX FIFO
    reg tog;              // to turn buttons off
    
    initial begin
        tog <= 1;
    end 

    // For debugging, we won't use a complex state machine. Instead, we rely on the buttons.
    // However, if you still want to show the FPGA's "mode," you can keep it simple:
    reg current_mode; // 0 = Idle, 1 = Active (just for LED debugging)
    always @(posedge clk_100MHz or posedge reset_btn) begin
        if (reset_btn) begin
            current_mode <= 0;
        end else begin
            // For debugging, toggle mode when writing or reading (optional)
            // or keep it simple and just show when RX FIFO is not empty.
            current_mode <= ~rx_empty; 
        end
    end

    // Assign signal_debugging to show current_mode or something meaningful.
    always @(*) begin
        // Just show if FIFO is not empty as a debug indicator
        signal_debugging = ~rx_empty;
    end
    
    always @(posedge clk_100MHz) begin
        if (input_switch) begin
            if (tog) begin
                tog <= 0;
                read_uart_btn <= 1;
                write_uart_btn <= 1;
            end else begin
                tog <= 1;
                read_uart_btn <= 0;
                write_uart_btn <= 0;
            end
        end
    end

    // Handle read and write flags on button presses
    always @(posedge clk_100MHz or posedge reset_btn) begin
        if (reset_btn) begin
            read_flag <= 0;
            write_flag <= 0;
            data_reg <= 0;
            write_data_reg <= 0;
        end else begin
            // On a button press, do a single read
            if (read_uart_btn && ~rx_empty) begin
                read_flag <= 1;
            end else begin
                read_flag <= 0;
            end

            // After reading, we can process the data if desired
            // For debugging, let's just pass it through unchanged or 
            // do a trivial operation. This is where you'd do your 
            // computations on data_reg if needed.
            if (read_flag) begin
                data_reg <= y_data; // trivial operation
            end

            // On a button press, do a single write
            if (write_uart_btn) begin
                write_data_reg <= data_reg;
                write_flag <= 1;
            end else begin
                write_flag <= 0;
            end
        end
    end

    // Instantiate the UART system (uart_top)
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
            .read_uart_btn(read_flag),      // For debugging, directly connect read_flag
            .write_uart_btn(write_flag),    // For debugging, directly connect write_flag
            .rx(rx),
            .rx_done_tick(rx_done_tick),
            .rx_full(rx_full),
            .rx_empty(rx_empty),
            .tx(tx),
            .signal_debugging(),
            .read_data(read_data),
            .write_data(write_data_reg),
            .tx_done_tick(tx_done_tick)
        );
        
      // instantiate things
      Filter1 #(
            .n(),               // Number of filter coefficients
            .datawidth()        // Bit-width of input and coefficients
        ) conv1 (
            .clk(clk_100MHz),                     // Clock signal
            .rst(reset_btn),                     // Reset signal
            .x_in(read_data),  // Input signal
            .y_out(y_data) // Filtered output
        );  

endmodule
