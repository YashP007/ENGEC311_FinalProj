# UART System with Debouncing, FIFO Buffers, and Baud Rate Generation

This README provides an in-depth explanation of the provided Verilog modules and how they work together to form a complete UART (Universal Asynchronous Receiver/Transmitter) system. The code and design approach are largely adapted from the reference book "FPGA Prototyping by Verilog Examples" (Xilinx Spartan-3 Version) by Dr. Pong P. Chu, and have been updated for use with an Artix-7 FPGA running at 100MHz.

## Table of Contents
1. [Overview of the System](#overview-of-the-system)
2. [Module Descriptions](#module-descriptions)
   - [Debounce Module (`debounce_explicit`)](#debounce-module-debounce_explicit)
   - [Baud Rate Generator (`baud_rate_generator`)](#baud-rate-generator-baud_rate_generator)
   - [UART Receiver (`uart_receiver`)](#uart-receiver-uart_receiver)
   - [UART Transmitter (`uart_transmitter`)](#uart-transmitter-uart_transmitter)
   - [FIFO Modules (`fifo`)](#fifo-modules-fifo)
   - [Top-Level UART Module (`uart_top`)](#top-level-uart-module-uart_top)
3. [Integration of the Modules](#integration-of-the-modules)
4. [Parameterization](#parameterization)
5. [How Data Flows Through the System](#how-data-flows-through-the-system)
6. [Usage and Customization](#usage-and-customization)
7. [References](#references)

---

## Overview of the System

A UART is a serial communication interface that allows data to be transmitted and received one bit at a time over a single data line (plus ground and optional flow control lines). Typically, UART communication is asynchronous, meaning no clock signal is shared between sender and receiver; both sides must agree on a communication speed (baud rate) and data format.

In this system, the UART is implemented using several building blocks:
- **Debounce logic** for pushbuttons: Ensures that pushbutton inputs are clean, stable signals rather than "bouncing" electrical signals.
- **Baud rate generator**: Creates a timing "tick" signal from a known FPGA clock (100MHz) at the required baud rate.
- **UART Receiver**: Captures serial input data and reassembles it into bytes.
- **UART Transmitter**: Sends bytes out serially according to the selected baud rate.
- **FIFOs**: Buffers that store data temporarily on both the receive (Rx) and transmit (Tx) sides. They allow backpressure handling and synchronization between slow button presses and continuous data streams.
- **Top-level module**: Integrates all these components, providing input/output signals and connecting the internal signals.

---

## Module Descriptions

### Debounce Module (`debounce_explicit`)

**Purpose:**  
Mechanical pushbuttons "bounce" and do not transition cleanly. The debounce module filters out short, spurious transitions so that the rest of the logic sees only a clean, stable signal.

**How It Works:**  
- It uses a finite state machine (FSM) and a counter to ensure that a signal (button press) remains stable for a predetermined amount of time (e.g., ~40ms).
- Parameters define how long the signal must be stable before considering it debounced.
- The module outputs:
  - `db_level`: A stable, debounced logic level (used mainly for switches).
  - `db_tick`: A one-clock-cycle wide pulse to indicate that a button press event has been validated (ideal for triggering actions).

**Key Signals:**
- `clk_100MHz`, `reset`: The system clock and reset.
- `btn`: The raw button input.
- `db_level`, `db_tick`: Clean output signals after debouncing.

### Baud Rate Generator (`baud_rate_generator`)

**Purpose:**  
This module takes the 100MHz system clock and divides it down to generate a "tick" signal at a rate corresponding to the required oversampling frequency for the UART line. For UART, typically the line is oversampled by a factor (often 16 times the baud rate).

**How It Works:**  
- A counter increments every clock cycle.
- Once the counter reaches a specified limit (derived from desired baud rate), it resets and produces a `tick` pulse.
- This `tick` is used by the receiver and transmitter to correctly time the sampling and shifting of bits.

**Key Parameters:**
- `M`: The terminal count for the counter. Derived from `(FPGA Clock Frequency) / (Baud Rate * Oversampling)`.
- `N`: The number of bits needed for the counter (determined by `log2(M)`).

**Key Signals:**
- `clk_100MHz`, `reset`: Input clock and reset.
- `tick`: Output pulse at the oversampling rate.

### UART Receiver (`uart_receiver`)

**Purpose:**  
The UART receiver listens to the incoming serial data line (`rx`) and reconstructs bytes from the serial bitstream once it detects a start bit.

**How It Works:**  
- The receiver uses a state machine with four states:
  1. **idle**: Wait for the `rx` line to go LOW (start bit).
  2. **start**: Validate the start bit over a predefined number of ticks.
  3. **data**: Shift in data bits, one at a time, aligned with the `tick` from the baud rate generator.
  4. **stop**: Wait and verify the stop bit.
- When a full data word (byte) is received and the stop bit is verified, `data_ready` goes HIGH for one cycle, and the reconstructed data is presented on `data_out`.

**Key Signals:**
- `rx`: Serial data input line.
- `sample_tick`: The timing tick from the baud rate generator.
- `data_ready`: Indicates that a full byte is available.
- `data_out`: The received byte.

### UART Transmitter (`uart_transmitter`)

**Purpose:**  
The UART transmitter takes a parallel data word and serializes it out via the `tx` line at the given baud rate.

**How It Works:**  
- The transmitter uses a state machine with four states:
  1. **idle**: `tx` line is held HIGH.
  2. **start**: Transmit the start bit (LOW).
  3. **data**: Shift out each data bit, one per oversampling period.
  4. **stop**: Transmit the stop bit(s) (HIGH).
- Once all bits (start, data, stop) have been transmitted, `tx_done` goes HIGH to indicate completion.

**Key Signals:**
- `tx_start`: Indicates data is ready to be transmitted (e.g., FIFO not empty).
- `data_in`: The parallel data word to transmit.
- `sample_tick`: Timing tick from the baud rate generator.
- `tx_done`: Signals the end of transmission.
- `tx`: Serial data output line.

### FIFO Modules (`fifo`)

**Purpose:**  
FIFOs (First-In-First-Out buffers) provide temporary storage to decouple when data arrives from when it is processed. In this UART system, there are two FIFOs:
- **Rx FIFO**: Stores received data words until the system reads them.
- **Tx FIFO**: Stores data words to be transmitted when the transmitter is ready.

**How They Work:**
- The FIFO uses memory arrays and read/write pointers.
- `write_to_fifo` and `read_from_fifo` inputs indicate when to push data in or pop data out.
- If the FIFO is full, no new data can be written; if it is empty, no data can be read.
- The FIFO logic updates pointers accordingly and sets `full`/`empty` flags.

**Key Parameters:**
- `DATA_SIZE`: Width of the data word stored in the FIFO.
- `ADDR_SPACE_EXP`: Determines the depth of the FIFO as `2^ADDR_SPACE_EXP`.

**Key Signals:**
- `write_to_fifo`, `read_from_fifo`
- `write_data_in`, `read_data_out`
- `full`, `empty`

### Top-Level UART Module (`uart_top`)

**Purpose:**  
The `uart_top` module ties together all the components:
- Instantiates debouncing for pushbuttons (reset, read, write).
- Instantiates the baud rate generator, UART transmitter, and UART receiver.
- Provides two FIFOs (one for Rx, one for Tx) connected to the UART receiver and transmitter respectively.
- Manages the flow of data from Rx to its FIFO and from the Tx FIFO to the transmitter line.

**How It Works:**
1. **Clock & Reset**: All modules share the 100MHz clock and the debounced reset signal.
2. **Baud Rate**: The `baud_rate_generator` creates the `tick` signal for sampling bits.
3. **Receiving Data**: The `uart_receiver` captures incoming bits on `rx` and, when a full word is received, writes it into the Rx FIFO.
4. **Transmitting Data**: When the user pushes the write button (debounced to `write_uart`), the data from `write_data` input is stored into the Tx FIFO. The transmitter takes data from the Tx FIFO, sends it out bit by bit on `tx`, and signals when done.
5. **Reading Data**: When the user pushes the read button (`read_uart`), a data word is popped from the Rx FIFO for external use.

**Key Interfaces:**
- Inputs: `clk_100MHz`, `reset_btn`, `read_uart_btn`, `write_uart_btn`, `rx`, `write_data`
- Outputs: `rx_done_tick`, `rx_full`, `rx_empty`, `tx`, `read_data`, `tx_done_tick`
- Internal connections: `tick` from `baud_rate_generator`, FIFOs connected to `uart_receiver` and `uart_transmitter`, debounced signals.

---

## Integration of the Modules

1. **Debouncing**: 
   Each pushbutton (`reset_btn`, `read_uart_btn`, `write_uart_btn`) is passed through a `debounce_explicit` module. This ensures that the signals used to reset the system and read/write data from FIFOs are stable and reliable.

2. **Baud Rate Generation**:
   The `baud_rate_generator` takes the stable system clock and reset signal and produces a `tick`. The `uart_receiver` and `uart_transmitter` use this `tick` as a timing reference for sampling and shifting data bits at the correct baud rate.

3. **UART Receiver and Rx FIFO**:
   The `uart_receiver` monitors `rx`. Once it captures a full byte and sets `data_ready`, that byte is immediately written into the Rx FIFO. The Rx FIFO can later be read out by asserting `read_uart`.

4. **UART Transmitter and Tx FIFO**:
   When the user wants to send data, they assert `write_uart`. This writes a byte from `write_data` into the Tx FIFO. The `uart_transmitter` continuously checks if the Tx FIFO is not empty. When it finds data, it sends it bit-by-bit out of `tx`, and once the byte is completely sent, it sets `tx_done_tick` and reads the next byte from the Tx FIFO if available.

---

## Parameterization

Many parameters are included to make the system flexible:
- **DBITS**: Number of data bits per transmitted/received word.
- **SB_TICK**: Number of tick counts that represent a stop bit duration (for oversampling).
- **BR_LIMIT**, **BR_BITS**: Control the baud rate by adjusting the counter limit and width in the `baud_rate_generator`.
- **FIFO_EXP**: Adjusts the depth of the FIFOs.

By changing these parameters, you can adapt the UART for different baud rates, data word sizes, and buffer depths.

---

## How Data Flows Through the System

1. **Receiving Data (Rx path)**:
   - Serial data arrives at `rx`.
   - The `uart_receiver` synchronously samples and reconstructs this data into a byte once the start bit is detected.
   - On completion, `rx_done_tick` is asserted and the byte is written into the Rx FIFO.
   - When the user presses the "read" button, after debouncing, the Rx FIFO outputs a stored byte (`read_data`) and removes it from the queue.

2. **Transmitting Data (Tx path)**:
   - The user provides a byte at `write_data` and presses the "write" button.
   - After debouncing, the byte is stored in the Tx FIFO.
   - The `uart_transmitter`, upon sensing that the Tx FIFO is not empty, pulls out the next byte and begins serial transmission:
     - Sends a start bit.
     - Sends the data bits, LSB first.
     - Sends the stop bit(s).
   - After transmission, `tx_done_tick` is asserted, indicating the byte has been fully sent.
   - The process repeats as long as new data is written into the Tx FIFO.

---

## Usage and Customization

- **Changing the Baud Rate**: 
  Adjust `BR_LIMIT` and `BR_BITS` in `uart_top` to match the desired baud rate. Precomputed examples are included as comments in the code.
  
- **Modifying Data Word Size**:
  Change `DBITS` in the `uart_top` module to handle larger or smaller words.

- **FIFO Depth**:
  Adjust `FIFO_EXP` to increase or decrease the FIFO buffer depth as needed.

**Note**: Ensure any changes to parameters are consistent throughout the system (e.g., baud rate settings in the generator and references in the receiver/transmitter).

---

## References

- Chu, Pong P. *FPGA Prototyping by Verilog Examples: Xilinx Spartan-3 Version.* Wiley.
- Xilinx Artix-7 FPGA documentation and datasheets.
- General UART and digital design textbooks and application notes.

---

By understanding each module's purpose, how they connect, and how data moves through the system, you can confidently use, modify, and extend this UART setup for various FPGA-based projects.
