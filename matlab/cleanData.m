LOW_THRESH = 7.0;  % TODO
HIGH_THRESH = 35.0;  % TODO
SAVE_PATH = "/Users/christian/Documents/summer2023/pupillometry_matlab/example_lowir2/";  % TODO
DATA_FILE = "lowir2_radii.mat";  % TODO
VIDEO_PATH = "/Users/christian/Documents/summer2023/pupillometry_matlab/example_lowir2/lowir2.avi";  % TODO
PEAKS_THRESHOLD = 10;
SMOOTH_N = 5;  % TODO

data = load(fullfile(SAVE_PATH, DATA_FILE));
R = data.R;

% Replace low values with nan.
n_below_low = sum(R < LOW_THRESH);
% fprintf("Replacing %f values below %f with nan\n", n_below_low, LOW_THRESH);
R(R(:, 2) < LOW_THRESH, 2) = nan;

% Replace high values with nan.
n_above_high = sum(R > HIGH_THRESH);
% fprintf("Replacing %f values above %f with nan\n", n_above_high, HIGH_THRESH);
R(R(:, 2) > HIGH_THRESH, 2) = nan;

% Interpolate between the nan values.
% Taken from
% https://www.mathworks.com/matlabcentral/answers/408164-how-to-interpolate-at-nan-values.
x = transpose(~isnan(R(:, 2)));
y = cumsum(x - diff([1, x])/ 2);
z = interp1(1:nnz(x), R(x, 2), y);
R(:, 2) = z;

% Smooth the data using moving n-point smoothing. By default, n = 5.
R(:, 2) = smooth(R(:, 2), SMOOTH_N);

% Save the cleaned data.
mat_save_file = fullfile(SAVE_PATH, "clean.mat");
save(mat_save_file, 'R');

csv_save_file = fullfile(SAVE_PATH, "clean.csv");
dlmwrite(csv_save_file, R, 'newline', 'pc', 'delimiter', ';');

% Find the peaks.
[pks, locs, w, p] = findpeaks(R(:, 2));
peak_heights = p(p > 10)
peak_locations = R(locs(p > 10), 1)

% Plot the data.
plotStatistics(csv_save_file, VIDEO_PATH);
