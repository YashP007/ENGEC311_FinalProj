% Main script to communicate with FPGA, send a signal, receive filtered data,
% and plot results.

clc;
clear;

% Parameters
COM_PORT = 'COM6';    % Replace with the actual COM port
BAUD_RATE = 9600;   % Match this with the FPGA UART configuration
Fs = 1000;            % Sampling frequency (Hz)
T = 0.3;                % Duration of signal (s)

% Generate a test signal
[t, original_signal] = generate_signal(Fs, T);

t = [0];
original_signal = [2,4,7,3,8,3];

% Initialize serial communication
device = uart_init(COM_PORT, BAUD_RATE);

% Send the signal to the FPGA and receive the filtered signal
filtered_signal = uart_communicate(device, original_signal);
delete(device);
%filtered_signal = filter_signal(original_signal, Fs); % Implementing the filter using matlab instead of fpga for comparison purposes only

% Plot the results
plot_signals(t, original_signal, filtered_signal, Fs);

% Close the serial connection
%delete(device);
clear device;
