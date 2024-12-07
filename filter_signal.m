function filtered_signal = filter_signal(original_signal, Fs)
% Filters the input signal using an FIR filter in MATLAB
% original_signal: The signal to be filtered
% Fs: Sampling frequency
% Returns:
%   filtered_signal: Filtered version of the input signal

    % FIR filter design parameters
    cutoff_freq = 100; % Cutoff frequency (Hz)
    filter_order = 50; % Filter order (number of taps)

    % Normalize cutoff frequency to Nyquist frequency
    nyquist_freq = Fs / 2;
    normalized_cutoff = cutoff_freq / nyquist_freq;

    % Design the FIR filter using a Hamming window
    fir_coeffs = fir1(filter_order, normalized_cutoff, 'low', hamming(filter_order + 1));

    % Apply the FIR filter to the signal
    filtered_signal = filter(fir_coeffs, 1, original_signal);

    % Display filter properties (for reference)
    fvtool(fir_coeffs, 1); % Visualize the filter response
    disp('MATLAB FIR filter applied.');
end


