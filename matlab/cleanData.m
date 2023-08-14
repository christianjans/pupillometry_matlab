LOW_THRESH = 7.0;  % TODO
HIGH_THRESH = 35.0;  % TODO, typical value is 35.
SAVE_PATH = "/Users/christian/Documents/summer2023/pupillometry_matlab/example_full4/";  % TODO
DATA_FILE = "fc2_save_2023-08-08-111558-0000_radii.mat";  % TODO
VIDEO_PATH = "/Users/christian/Documents/summer2023/matlab/my_data/full4/fc2_save_2023-08-08-111558-0000.avi";  % TODO
N_PEAKS = 10;  % TODO, typical value is 10.
% PEAKS_THRESHOLD = 5;
SMOOTH_N = 5;  % TODO

data = load(fullfile(SAVE_PATH, DATA_FILE));
R = data.R;

% Replace low values with nan.
n_below_low = sum(R(:, 2) < LOW_THRESH);
fprintf(1, "Replacing %d values below %f with nan\n", n_below_low, LOW_THRESH);
R(R(:, 2) < LOW_THRESH, 2) = nan;

% Replace high values with nan.
n_above_high = sum(R(:, 2) > HIGH_THRESH);
fprintf(1, "Replacing %d values above %f with nan\n", n_above_high, HIGH_THRESH);
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
[sorted_prominence, sorted_prominence_indices] = sort(p, 'descend');

fprintf(1, "Peak heights: [");
for i = 1:N_PEAKS
    if i == N_PEAKS
        fprintf(1, "%f]\n", sorted_prominence(i));
    else
        fprintf(1, "%f, ", sorted_prominence(i));
    end
end

fprintf(1, "Peak locations: [");
for i = 1:N_PEAKS
    if i == N_PEAKS
        fprintf(1, "%d]\n", locs(sorted_prominence_indices(i)));
    else
        fprintf(1, "%d, ", R(locs(sorted_prominence_indices(i)), 1));
    end
end

% Find the troughs
[troughs, locs, w, p] = findpeaks(-R(:, 2));
[sorted_prominence, sorted_prominence_indices] = sort(p, 'descend');

fprintf(1, "Trough locations: [");
for i = 1:N_PEAKS
    if i == N_PEAKS
        fprintf(1, "%f]\n", sorted_prominence(i));
    else
        fprintf(1, "%f, ", sorted_prominence(i));
    end
end

fprintf(1, "Trough locations: [");
for i = 1:N_PEAKS
    if i == N_PEAKS
        fprintf(1, "%d]\n", locs(sorted_prominence_indices(i)));
    else
        fprintf(1, "%d, ", R(locs(sorted_prominence_indices(i)), 1));
    end
end

% Plot the data.
plotStatistics(csv_save_file, VIDEO_PATH);
