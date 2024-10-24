% List of piano keys from A0 to C8 (88 keys)
pianoKeys = {'A0', 'Bb0', 'B0', 'C1', 'Db1', 'D1', 'Eb1', 'E1', 'F1', 'Gb1', 'G1', 'Ab1', ...
             'A1', 'Bb1', 'B1', 'C2', 'Db2', 'D2', 'Eb2', 'E2', 'F2', 'Gb2', 'G2', 'Ab2', ...
             'A2', 'Bb2', 'B2', 'C3', 'Db3', 'D3', 'Eb3', 'E3', 'F3', 'Gb3', 'G3', 'Ab3', ...
             'A3', 'Bb3', 'B3', 'C4', 'Db4', 'D4', 'Eb4', 'E4', 'F4', 'Gb4', 'G4', 'Ab4', ...
             'A4', 'Bb4', 'B4', 'C5', 'Db5', 'D5', 'Eb5', 'E5', 'F5', 'Gb5', 'G5', 'Ab5', ...
             'A5', 'Bb5', 'B5', 'C6', 'Db6', 'D6', 'Eb6', 'E6', 'F6', 'Gb6', 'G6', 'Ab6', ...
             'A6', 'Bb6', 'B6', 'C7', 'Db7', 'D7', 'Eb7', 'E7', 'F7', 'Gb7', 'G7', 'Ab7', ...
             'A7', 'Bb7', 'B7', 'C8'};

% Initialize storage for frequency-magnitude matrices
freq_mag_struct = struct();  % Structure to store freq_mag_notename matrices
maxFreq = 3000;              % Maximum frequency to consider

% Loop through all 88 notes
fprintf('Processing finished:');
for i = 1:88
    % Read the corresponding .wav file
    fileName = ['piano-wav/', pianoKeys{i}, '.wav'];
    [audioData, Fs] = audioread(fileName);
    
    % Compute FFT
    n = length(audioData);        % Number of samples
    y_fft = fft(audioData);       % Compute the FFT
    f = (0:n-1) * (Fs / n);       % Frequency vector

    % Limit to positive frequencies (Nyquist reduction)
    y_fft = y_fft(1:floor(n/2));
    f = f(1:floor(n/2));

    % Filter frequencies <= maxFreq
    validFreqIdx = f <= maxFreq;
    f = f(validFreqIdx);
    y_fft = y_fft(validFreqIdx);

    % Compute magnitudes and normalize by sampling rate
    mag = abs(y_fft) / Fs;  
    globalMax = max(mag);  % Maximum magnitude for normalization

    % Initialize arrays for storing selected frequencies and magnitudes
    temp_f = [];
    temp_mag = [];

    % Split frequencies into 20 Hz bins
    freqBins = 0:20:maxFreq;

    for j = 1:length(freqBins)-1
        % Find indices within the current 20 Hz bin
        binIdx = (f >= freqBins(j)) & (f < freqBins(j+1));
        bin_frequencies = f(binIdx);
        bin_magnitudes = mag(binIdx);

        % If the bin is non-empty, find the max magnitude
        if ~isempty(bin_magnitudes)
            [maxMag, maxIdx] = max(bin_magnitudes);

            % Add to the results if above threshold (globalMax / 10)
            if maxMag >= globalMax / 10
                temp_f = [temp_f, bin_frequencies(maxIdx)];
                temp_mag = [temp_mag, maxMag / globalMax];  % Normalize magnitude
            end
        end
    end

    % Remove close frequency spikes (< 40 Hz difference)
    if ~isempty(temp_f)
        for j = 1:length(temp_f)-1
            if abs(temp_f(j+1) - temp_f(j)) < 40
                if temp_mag(j) < temp_mag(j+1)
                    temp_f(j) = NaN;  % Mark for removal
                    temp_mag(j) = NaN;
                else
                    temp_f(j+1) = NaN;
                    temp_mag(j+1) = NaN;
                end
            end
        end

        % Remove NaN entries
        temp_f = temp_f(~isnan(temp_f));
        temp_mag = temp_mag(~isnan(temp_mag));
    end

    % Normalize by the first spike magnitude (if it exists)
    if ~isempty(temp_mag)
        firstSpikeMagnitude = temp_mag(1);
        temp_mag = temp_mag / firstSpikeMagnitude;
    end

    % Create the frequency-magnitude matrix
    freq_magnitude = [temp_f; temp_mag];

    % Store the matrix in the struct with dynamic field name
    dynamic_field = sprintf('freq_mag_%s', pianoKeys{i});
    freq_mag_struct.(dynamic_field) = freq_magnitude;

    % Optional: Display the matrix for the current note
    fprintf('%s \n', pianoKeys{i});
end

% The result is stored in the struct `freq_mag_struct`
