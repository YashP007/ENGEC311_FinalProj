%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Class: ENGEC311: Final Project
%%%% Group - 6 Digital Filtering Using HDL
%%%% Finalized Date: 12/09/24
%%%% Author: Yash Patel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_signals(t, original_signal, filtered_signal, Fs)
% Plots the original and filtered signals in time and frequency domains
% t: Time vector
% original_signal: Original input signal
% filtered_signal: Filtered signal received from FPGA
% Fs: Sampling frequency

    % Compute frequency content
    N = length(original_signal);
    f = linspace(0, Fs/2, N/2); % Frequency axis
    original_fft = abs(fft(original_signal)/N); % Normalize FFT
    filtered_fft = abs(fft(filtered_signal)/N);

    % Plot time domain
    figure;
    subplot(3, 2, 1);
    plot(t, original_signal);
    title('Original Signal (Time Domain)');
    xlabel('Time (s)');
    ylabel('Amplitude');

    subplot(3, 2, 3);
    plot(t, filtered_signal);
    title('Filtered Signal (Time Domain)');
    xlabel('Time (s)');
    ylabel('Amplitude');

    % Plot frequency domain
    subplot(3, 2, 2);
    plot(f, 2*original_fft(1:N/2)); % Multiply by 2 for single-sided spectrum
    title('Original Signal (Frequency Domain)');
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');

    subplot(3, 2, 4);
    plot(f, 2*filtered_fft(1:N/2)); % Multiply by 2 for single-sided spectrum
    title('Filtered Signal (Frequency Domain)');
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');

    % Plot combined time and frequency
    subplot(3, 2, [5, 6]);
    hold on;
    plot(t, original_signal, 'b', 'DisplayName', 'Original Signal');
    plot(t, filtered_signal, 'r', 'DisplayName', 'Filtered Signal');
    legend;
    title('Overlay (Time Domain)');
    xlabel('Time (s)');
    ylabel('Amplitude');
    hold off;

    disp('Plots generated.');
end
