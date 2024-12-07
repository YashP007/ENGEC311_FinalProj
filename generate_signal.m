function [t, signal] = generate_signal(Fs, T)
% Generates a test signal as a combination of sinusoids
% Fs: Sampling frequency
% T: Duration of signal
% Returns:
%   t: Time vector
%   signal: Generated signal

    t = 0:1/Fs:T-1/Fs; % Time vector
    signal = sin(2*pi*50*t) + 0.5*sin(2*pi*120*t); % 50 Hz and 120 Hz components
    signal = signal / max(abs(signal)); % Normalize to fit within [-1, 1]
end
