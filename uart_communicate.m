function filtered_signal = uart_communicate(device, signal)
% Communicates with the FPGA via UART
% device: Serial port object
% signal: Signal to be sent to FPGA
% Returns: Filtered signal received from FPGA

    % Scale signal to 8-bit range (0-255)
    %signal_scaled = uint8((signal + 1) * 127.5);
    signal_scaled = uint8(signal);

    write(device, signal_scaled, "uint8");
    fprintf("sending a %d\n", signal_scaled);
   % for val = signal_scaled
   %     fprintf("sending a %d\n", val);
   %     % Send the signal to FPGA
   %     write(device, val, "uint8");
   % end

    % Receive filtered signal from FPGA
    while (1==1)
        filtered_scaled = read(device, 1, "uint8");
        disp(filtered_scaled);
    end

    filtered_scaled = [];
    while length(filtered_scaled) < 2  % We expect 2 bytes
        % Read 2 bytes of data from FPGA if available
        if device.NumBytesAvailable >= 2
            filtered_scaled = read(device, 2, "uint8");
            disp('Filtered signal received from FPGA:');
            disp(filtered_scaled);
        end
    end
    
    % Convert back to original range [-1, 1]
    %filtered_signal = double(filtered_scaled) / 127.5 - 1;
    filtered_signal = filtered_scaled;
end
