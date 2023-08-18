% A script to clean the raw pupil measurement data.
%
% Inputs:
%     LOW_THRESH:  Remove all pupil size values below this number.
%
%     HIGH_THRESH: Remove all pupil size values above this number.
%
%     SAVE_PATH:   The path to save the cleaned data.
%
%     VIDEO_PATH:  The path to the video analyzed to produce the original
%                  pupil data.
%
%     N_PEAKS:     The number of peaks to show, in descending order of
%                  prominence.
%
%     SMOOTH_N:    The number of points to use in the smoothing averaging.
%
% Outputs:
%     clean.csv:   The cleaned data in CSV format.
%
%     clean.mat:   The cleaned data in .mat format.
%
%     Peak values: In the command window, a list of the prominences (the
%                  minimum vertical distance that the signal must descend
%                  on either side of the peak before either climing back to
%                  a higher level than the peak or reaching an endpoint) of
%                  the N_PEAKS most prominent peaks is printed. Further,
%                  the locations (the frame number at which the peak
%                  occurs) are also printed in respective order. The same
%                  is done for troughs in the graph.

LOW_THRESH = 7.0;  % TODO
HIGH_THRESH = 20.0;  % TODO, typical value is 35.
SAVE_PATH = "/Users/christian/Documents/summer2023/pupillometry_matlab/example_full5/";  % TODO
DATA_FILE = "fc2_save_2023-08-09-103031-0000_radii.mat";  % TODO
VIDEO_PATH = "/Users/christian/Documents/summer2023/matlab/my_data/full5/fc2_save_2023-08-09-103031-0000.avi";  % TODO
N_PEAKS = 10;  % TODO, typical value is 10.
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
        fprintf(1, "%d]\n", R(locs(sorted_prominence_indices(i))));
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
