% List of piano keys from A0 to C8 (88 keys)
pianoKeys = {'A0', 'Bb0', 'B0', 'C1', 'Db1', 'D1', 'Eb1', 'E1', 'F1', 'Gb1', 'G1', 'Ab1', ...
             'A1', 'Bb1', 'B1', 'C2', 'Db2', 'D2', 'Eb2', 'E2', 'F2', 'Gb2', 'G2', 'Ab2', ...
             'A2', 'Bb2', 'B2', 'C3', 'Db3', 'D3', 'Eb3', 'E3', 'F3', 'Gb3', 'G3', 'Ab3', ...
             'A3', 'Bb3', 'B3', 'C4', 'Db4', 'D4', 'Eb4', 'E4', 'F4', 'Gb4', 'G4', 'Ab4', ...
             'A4', 'Bb4', 'B4', 'C5', 'Db5', 'D5', 'Eb5', 'E5', 'F5', 'Gb5', 'G5', 'Ab5', ...
             'A5', 'Bb5', 'B5', 'C6', 'Db6', 'D6', 'Eb6', 'E6', 'F6', 'Gb6', 'G6', 'Ab6', ...
             'A6', 'Bb6', 'B6', 'C7', 'Db7', 'D7', 'Eb7', 'E7', 'F7', 'Gb7', 'G7', 'Ab7', ...
             'A7', 'Bb7', 'B7', 'C8'};

% Create a new folder for WAV files if it doesn't exist
outputFolder = 'piano-wav';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Loop through all MP3 files and convert to WAV
for i = 1:88
    mp3File = ['piano-mp3/', pianoKeys{i}, '.mp3'];
    wavFile = [outputFolder, '/', pianoKeys{i}, '.wav'];

    % Read the MP3 file
    [audio, Fs] = audioread(mp3File);

    % Write the audio data to a WAV file
    audiowrite(wavFile, audio, Fs);
    fprintf('Converted %s to %s\n', mp3File, wavFile);
end