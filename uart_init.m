%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Class: ENGEC311: Final Project
%%%% Group - 6 Digital Filtering Using HDL
%%%% Finalized Date: 12/09/24
%%%% Author: Yash Patel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function device = uart_init(COM_PORT, BAUD_RATE)
% Initializes UART communication
% COM_PORT: Serial port (e.g., 'COM3')
% BAUD_RATE: Baud rate for communication
% Returns: Serial port object

    device = serialport(COM_PORT, BAUD_RATE); % Create serial port object
    device.Timeout = 15; % Set timeout to 5 seconds
    %device.InputBufferSize = 8;
    disp('Serial communication initialized.');
end
