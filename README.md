# Digitial Filtering and Convolutions using HDL Programming and Design
## ENGEC311: Final Project
### Team members: Yash Patel, Heewon Park, Vanshika Chaddha, Alexander Bernhardt
This README provides an in-depth explanation of the provided Verilog modules and how they work together to form a complete UART (Universal Asynchronous Receiver/Transmitter) system. The code and design approach are largely adapted from the reference book "FPGA Prototyping by Verilog Examples" (Xilinx Spartan-3 Version) by Dr. Pong P. Chu, and have been updated for use with an Artix-7 FPGA running at 100MHz.

---

## Table of Contents
1. [Overview of the System](#overview-of-the-system)
2. [Three Main Configurations](#three-main-configurations)
3. [Module Descriptions](#module-descriptions)
4. [Integration of the Modules](#integration-of-the-modules)
5. [Parameterization](#parameterization)
6. [How Data Flows Through the System](#how-data-flows-through-the-system)
7. [Usage and Customization](#usage-and-customization)
8. [how to run the code](#How-to-run-the-code)
9. [References](#references)

---

## Overview of the System

A UART system allows asynchronous serial communication by transmitting and receiving data one bit at a time. This system integrates debouncing, FIFO buffers, baud rate generation, and data filtering through FIR filters (in selected modes). It supports flexible operation with different configurations to cater to debugging, automated functionality, and data processing.

---

## Three Main Configurations

This design includes three main configurations to demonstrate UART functionality:

1. **Manual Debugging (`main_debugging`)**:
   - Operates based on pushbuttons (`read_uart_btn`, `write_uart_btn`).
   - Used for simple read and transmit functionality without data filtering.
   - Suitable for initial testing and debugging.

2. **Automated UART (`main_automated`)**:
   - Automatically reads from the RX FIFO and transmits the data back via TX FIFO.
   - Requires no external control signals, ideal for continuous data communication.
   - Does not apply any data filtering.

3. **Filtered Data Processing (`main_btn`)**:
   - Incorporates a FIR (Finite Impulse Response) filter for data processing.
   - A switch enables the filtering functionality, allowing input data to pass through an SOS filter before being transmitted.
   - Best suited for applications requiring signal filtering (e.g., noise reduction).

---

## Module Descriptions

### 1. Debounce Module (`debounce_explicit`)
Filters noisy button signals to produce clean, stable outputs. It generates:
- `db_tick`: A one-cycle pulse for button press events.
- `db_level`: A stable level signal for switches.

### 2. Baud Rate Generator (`baud_rate_generator`)
Generates timing pulses (`tick`) for the UART system based on the desired baud rate. Configurable for different rates by adjusting the counter limit (`M`).

### 3. UART Receiver (`uart_receiver`)
Reconstructs parallel data bytes from the serial input (`rx`). Uses a state machine to detect start, data, and stop bits.

### 4. UART Transmitter (`uart_transmitter`)
Serializes parallel data bytes for transmission via the `tx` line. Handles start, data, and stop bits according to UART protocol.

### 5. FIFO Modules (`fifo`)
Provide buffering for received and transmitted data. Configurable depth and data width.

### 6. FIR Filter Module SOS (`FIR_Filter1`)
Processes input data using a finite impulse response (FIR) filter with predetermined coefficients. Applied in the `main_btn` configuration for filtering data.

### 7. Convolution Filter (`convolution`)
Processes input data using convolution with configurable coefficients. Applied in the `main_btn` configuration for filtering data.

### 8. Top-Level UART Module (`uart_top`)
Integrates all modules and manages the flow of data between RX/TX FIFOs, UART modules, and external interfaces.

---

## Integration of the Modules

1. **Debouncing**:
   Ensures stable input signals for reset, read, and write operations.

2. **Baud Rate Generation**:
   Synchronizes the UART modules by generating a timing pulse at the configured baud rate.

3. **UART Modules and FIFOs**:
   Data flows through RX FIFO after being received by the UART receiver and is transmitted via TX FIFO and the UART transmitter.

4. **Filtering in `main_btn`**:
   Input data is processed through a FIR filter before transmission, adding functionality for applications requiring signal enhancement or noise reduction.

---

## Parameterization

The system is highly configurable, allowing adaptation to various applications:
- **Data Width (`DBITS`)**: Adjust for different word sizes.
- **FIFO Depth (`FIFO_EXP`)**: Increase or decrease buffer size.
- **Baud Rate**: Set by modifying `BR_LIMIT` and `BR_BITS` in the baud rate generator.

---

## How Data Flows Through the System

1. **Receiving Data**:
   - The UART receiver reconstructs bytes from the serial input.
   - These bytes are stored in the RX FIFO for processing or reading.

2. **Transmitting Data**:
   - Data is written to the TX FIFO via the UART transmitter.
   - The UART transmitter serializes the bytes for transmission via the `tx` line.

3. **Filtering in `main_btn`**:
   - Data from RX FIFO passes through the FIR filter before being stored in TX FIFO for transmission.

---

## Usage and Customization

### Simulation
- Use provided testbenches to simulate each configuration.

### Synthesis
- Synthesize the desired configuration using your FPGA development environment.

### Customization
- **To Enable Filtering**: Use `main_btn` and connect the FIR filter to the RX data path.
- **To Adjust FIFO Depth**: Modify `FIFO_EXP` to change buffer size.
- **To Change Baud Rate**: Update `BR_LIMIT` in the baud rate generator.

---
## How to run the code

1. install all the files from the github
2. open matlab and vivado
3. run .m files on matlab and .v files on vivado
4. make sure your FPGA is connected to the properly and check which COM# it is connected to
5. code the corresponding COM# fpga is connected into the matlab file
6. run the bitstream of the .v files
7. then run the matlab file
8. switch the _____ port up and down
9. now you will be able to se data recieving and transmitting
---

## References

- Pong P. Chu, *FPGA Prototyping by Verilog Examples*.
- Xilinx Artix-7 FPGA documentation.
- UART protocol standards and application notes.

---

By understanding these configurations, you can leverage this UART system for debugging, continuous communication, or data filtering applications.
