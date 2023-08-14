function plotStatistics(csv_file, video_file)

%% Load data

if contains(csv_file, "DLC")
    FRAME_INDEX = 1;
    % TOP_X_INDEX = 2;
    % TOP_Y_INDEX = 3;
    % BOTTOM_X_INDEX = 5;
    % BOTTOM_Y_INDEX = 6;
    LEFT_X_INDEX = 8;
    LEFT_Y_INDEX = 9;
    RIGHT_X_INDEX = 11;
    RIGHT_Y_INDEX = 12;
    % TR_X_INDEX = 14;
    % TR_Y_INDEX = 15;
    % BR_X_INDEX = 17;
    % BR_Y_INDEX = 18;
    % BL_X_INDEX = 20;
    % BL_Y_INDEX = 21;
    % TL_X_INDEX = 23;
    % TL_Y_INDEX = 24;
    % CENTER_X_INDEX = 26;
    % CENTER_Y_INDEX = 27;

    csv_table = readtable(csv_file);

    data = zeros(height(csv_table), 2);

    left_xs = csv_table{:, LEFT_X_INDEX};
    left_ys = csv_table{:, LEFT_Y_INDEX};
    right_xs = csv_table{:, RIGHT_X_INDEX};
    right_ys = csv_table{:, RIGHT_Y_INDEX};

    distances = sqrt((right_xs - left_xs) .^ 2 + (right_ys - left_ys) .^ 2);

    data(:, 1) = csv_table{:, FRAME_INDEX} + 1;
    data(:, 2) = distances;
else
    data = load(csv_file);
end


%% Read video data.

obj = VideoReader(video_file);
fs = obj.FrameRate;


%% Data figures

figure

subplot(2, 3, 1), plot(data(:, 1), data(:, 2));
title("smoothed"), xlabel("frame"), ylabel("pixels")

subplot(2, 3, 2), plot(data(:, 1), zscore(data(:, 2)))
title("zscore of smoothed"), xlabel("frame"), ylabel("pixels")

subplot(2, 3, 4), histogram(zscore(data(:, 2)));
title("zscore of smoothed"), xlabel("frame")

subplot(2, 3, 6), plot(data(1:end-1, 1), diff(data(:, 2)) ./ (diff(data(:, 1)) / fs));
title("smoothed rate of change"), xlabel("frame"), ylabel("pixels/s")

% subplot(2, 3, 2), plot(data(:, 1), smooth(data(:, 2)));
% title("smoothed"), xlabel("frame"), ylabel("pixels")

% subplot(2, 3, 3), plot(data(:, 1), zscore(smooth(data(:, 2))));
% title("zscore of smoothed"), xlabel("frame")

% subplot(2, 3, 4), histogram(zscore(smooth(data(:, 2))));
% title("zscore of smoothed"), xlabel("frame")

% subplot(2, 3, 6), plot(data(1:end-1, 1), smooth(diff(data(:, 2)) ./ (diff(data(:, 1)) / fs)));
% title("smoothed rate of change"), xlabel("frame"), ylabel("pixels/s")


%% FFT

clear data_fft
clear data_power
N = length(data);
xdft = fft(smooth(data(:, 2)));
xdft = xdft(1:N/2+1);  % Trim the amount of data we show.
psdx = (1/(fs*N)) * abs(xdft).^2;  % Create the power spectrum.
psdx(2:end-1) = 2*psdx(2:end-1);  % Enlarge tail-end values.
freq = 0:fs/length(data(:, 2)):fs/2;
% [psdx, freq] = pspectrum(data(:, 2), fs);

% subplot(2, 3, 5), plot(freq, pow2db(psdx));
subplot(2, 3, 5), plot(freq, psdx);
xlabel("Hz")
title("power spectrum")

end
