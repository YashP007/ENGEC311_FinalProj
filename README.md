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
8. [How to use this Code](#How-to-use-this-Code)
9. [Video Demonstration](#Video-Demonstration-and-Code-Explanation)
10. [References](#references)

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
   - This configuration is functional and has been verified that it can receive and send the same data back out. 

2. **Automated UART (`main_automated`)**:
   - Automatically reads from the RX FIFO and transmits the data back via TX FIFO.
   - Requires no external control signals, ideal for continuous data communication.
   - Does not apply any data filtering.
   - This module was implemented and tested but did not seem to receive or transmit any data, which is why we made the following module. 

3. **Filtered Data Processing (`main_btn`)**:
   - Incorporates a FIR (Finite Impulse Response) filter for data processing.
   - A switch enables the filtering functionality, allowing input data to pass through an SOS filter before being transmitted.
   - Best suited for applications requiring signal filtering (e.g., noise reduction).
   - The functionality of this module is shown in the video. 
   - **Submitted generated bitstream for this configuration**

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
Processes input data using convolution with configurable coefficients. This module is currently not linked to any of the main modules, but can easily be configured to. Future work involved integrating this module and the SOS FIR filter module into one main module with MUX and selection lines to select between SOS and Convolution. 

### 8. Top-Level UART Module (`uart_top`)
Integrates all modules and manages the flow of data between RX/TX FIFOs, UART modules, and external interfaces. There are three configurations of this main module each performing a different operation as shown above. 

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
## How to use this Code
### 1. Install Required Files:
- Clone or download all the necessary project files from the GitHub repository.
### 2. Set Up Tools:
- Open MATLAB for data handling and analysis.
- Open Vivado for FPGA programming.
### 3. Connect the FPGA:
- Ensure your FPGA board is properly connected to your computer.
- Identify the COM port (e.g., COM3, COM4, etc.) to which the FPGA is connected.
### 4. Configure MATLAB for Communication:
- Locate the MATLAB file (main.m) and edit it.
- Update the code to specify the correct COM port number where the FPGA is connected.
- If it is not working for some reason, ensure you only have one communication port open with the device. 
### 5. Load the Bitstream:
- Use Vivado to load the bitstream (.bit) of the hardware design onto the FPGA. This includes the main hardware module (main.v).
   - Open the Vivado project.
   - Generate the bitstream if it's not already generated.
   - Program the FPGA with the bitstream.
### 6. Put Switch (Switch 1) to "high" to enable reading
- Additionally, you can press the reset button to clear any past values.
### 7. Run the MATLAB Script:
-  Run the MATLAB script (main.m) to initiate data transmission and reception with the FPGA.
### 8. Verify Operation:
- Now, to push values out one by one, toggle the switch up and down. Allows new data to be pushed into the RX FIFO, resulting in data being pushed out.
- As data is pushed out it is sent through the filtering module, and pushed into the TX FIFO. Overtime, as new values are pushed into the TX FIFO data will be transmitted back to MATLAB. 
- Observe the data being transmitted and received between MATLAB and the FPGA.

---
## Video Demonstration and Code Explanation
Please find our linked video demonstration and explanation of our modules and code here: [https://drive.google.com/file/d/1k5ezgEhREktMXlYjHHgzApF3g4-xmtCg/view?usp=sharing]

---

## References

- Pong P. Chu, *FPGA Prototyping by Verilog Examples*.
- Xilinx Artix-7 FPGA documentation. (Copy Provided within the `Constraints` Sub-Directory)
- UART protocol standards and application notes.

---
## Extra Materials



By understanding these configurations, you can leverage this UART system for debugging, continuous communication, or data filtering applications.
