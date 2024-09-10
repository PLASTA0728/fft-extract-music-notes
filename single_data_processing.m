% File name for the single .wav file (C4.wav)
fileName = 'C4_G4_C5.wav';

% Initialize storage for audio data, sampling rate, frequency, and magnitude
audioData = []; % Store the audio data
Fs = 0;         % Store the sampling rate
freq_magnitude = []; % Store frequency and magnitude matrix for the file

% Define the maximum frequency range for the plot (0-3000 Hz)
maxFreq = 3000;

% Read the .wav file
[audioData, Fs] = audioread(fileName);

% Plot settings
figure;

% Apply FFT and reduce Nyquist effect (aliasing)
n = length(audioData);         % Number of samples
y_fft = fft(audioData);        % Compute the FFT
f = (0:n-1)*(Fs/n);            % Frequency vector

% Nyquist effect reduction: limit the FFT to the positive frequencies
y_fft = y_fft(1:floor(n/2));   % Take only the first half (positive frequencies)
f = f(1:floor(n/2));           % Corresponding frequency range

% Filter to only include frequencies within 0-3000 Hz
validFreqIdx = f <= maxFreq;   % Find frequencies <= 3000 Hz
f = f(validFreqIdx);           % Filter frequencies
y_fft = y_fft(validFreqIdx);   % Filter FFT results

% Compute magnitude and normalize by sampling rate
mag = abs(y_fft);              % Magnitudes of the FFT
globalMax = max(mag);          % Find the global maximum magnitude

% Split frequencies into 20 Hz intervals
freqBins = 0:20:maxFreq;       % Create frequency bins of 20 Hz intervals
new_f = [];                    % Initialize new frequency array
new_mag = [];                  % Initialize new magnitude array

% Storage for intermediate results
temp_f = [];  % Store frequencies
temp_mag = []; % Store magnitudes

% Loop over each 20 Hz interval
for j = 1:length(freqBins)-1
    % Find the indices of frequencies within the current 20 Hz bin
    binIdx = (f >= freqBins(j)) & (f < freqBins(j+1));
    bin_frequencies = f(binIdx);  % Frequencies in the current bin
    bin_magnitudes = mag(binIdx); % Magnitudes in the current bin
    
    % If there are any frequencies in this bin, find the maximum magnitude
    if ~isempty(bin_magnitudes)
        [maxMag, maxIdx] = max(bin_magnitudes); % Find max magnitude in the bin
        
        % Check if the max magnitude is greater than 1/20th of the global maximum
        if maxMag >= globalMax / 20
            % Add the maximum frequency and its magnitude to the new arrays
            temp_f = [temp_f, bin_frequencies(maxIdx)];  % Maximum frequency in this bin
            temp_mag = [temp_mag, maxMag];   % Normalized maximum magnitude in this bin
        end
    end
end

% Check minimum frequency and cancel spikes based on neighboring ranges
minFreq = min(temp_f); % Find the minimum frequency in the current results

% Find the magnitude corresponding to the lowest frequency
minFreqMag = temp_mag(temp_f == minFreq);

if minFreq > 40
    % Create a copy of the temporary arrays for modification
    final_f = temp_f;
    final_mag = temp_mag;
    
    % Identify and remove lower magnitude spikes if frequency difference < 40 Hz
    for j = 1:length(final_f)-1
        if abs(final_f(j+1) - final_f(j)) < 40
            % Compare magnitudes and remove the lower one
            if final_mag(j) < final_mag(j+1)
                final_f(j) = NaN;  % Mark the lower frequency to be removed
                final_mag(j) = NaN; % Mark the lower magnitude to be removed
            else
                final_f(j+1) = NaN; % Mark the lower frequency to be removed
                final_mag(j+1) = NaN; % Mark the lower magnitude to be removed
            end
        end
    end
    
    % Remove NaN values (lower spikes)
    final_f = final_f(~isnan(final_f));
    final_mag = final_mag(~isnan(final_mag));
    
    % Update the results
    temp_f = final_f;
    temp_mag = final_mag;
end


% Create frequency and magnitude matrix with frequencies in the first row, normalized magnitudes in the second row
freq_magnitude = [temp_f; normalized_mag];  % Create a 2-row matrix: 1st row frequencies, 2nd row normalized magnitudes

% Plot the FFT magnitude spectrum as spikes (stem plot without circles)
stem(temp_f, normalized_mag, 'Marker', 'none', 'LineWidth', 1.2); % Remove markers on spikes
title('FFT of Chord (Normalized Magnitude)');
xlabel('Frequency (Hz)');
ylabel('Normalized Magnitude');
xlim([0 3000]);  % Set frequency range from 0 to 3000 Hz

% Output frequency and magnitude matrix
freq_mag_C4 = freq_magnitude;  % Frequencies and magnitudes for C4.wav

% Display the frequency and magnitude matrix in the command window (optional)
disp('Normalized Frequency and Magnitude matrix for C4.wav:');
disp(freq_mag_C4);
