% MATLAB code to interface with FPGA over UART for convolution and signal filtering

% Specify the COM port and parameters (adjust the COM port as per your system)
serialPort = 'COM4';  % Change this to your serial port (e.g., COMx on Windows or /dev/ttyUSBx on Linux/Mac)
baudRate = 115200;      % Baud rate for communication (ensure this matches FPGA design)
dataBits = 8;         % Data bits (FPGA expects 8-bit communication)
parity = 'none';      % No parity bit
stopBits = 1;         % Stop bits


% Create the serial object
fpgaSerial = serialport(serialPort, 'BaudRate', baudRate, 'Terminator', 'LF', ...
                    'Timeout', 30, 'DataBits', dataBits, 'Parity', parity, 'StopBits', stopBits);
flush(fpgaSerial); % Clear UART buffers

% Open the serial port
fopen(fpgaSerial);

% Send the SET command to the FPGA to initialize the convolution and filtering process
% The "SET" command could be specific to your FPGA program, make sure it matches the protocol
fprintf(fpgaSerial, 'SET');  % This assumes 'SET' is the command for starting the operation

% Optionally, you can send data for convolution or filtering
% For example, sending a byte (if sending a filter input):
filterInputData = uint8(42);  % Example data (byte to be filtered)
fwrite(fpgaSerial, filterInputData, 'uint8');  % Send a single byte to FPGA

% Wait for the FPGA to process the command and perform the convolution/filtering
pause(2);  % Adjust the pause duration as needed, based on FPGA processing time

% Now, retrieve the result from the FPGA (assuming it returns a filtered byte)
result = fread(fpgaSerial, 1, 'uint8');  % Reading one byte of data

% Process the result (e.g., display the filtered value)
disp(['Filtered/Convolved result from FPGA: ', num2str(result)]);

% Close the serial port once done
fclose(fpgaSerial);
delete(fpgaSerial);
clear fpgaSerial;
