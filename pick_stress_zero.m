function Szero = pick_stress_zero(Triax, run_index_i, run_index_f)
% PICK_STRESS_ZERO  Interactively select the baseline zero for differential stress.
%
%   Szero = pick_stress_zero(Triax, run_index_i, run_index_f)
%
%   Opens a figure showing the full differential stress time series with
%   run boundaries marked. The user zooms into the pre-run baseline region,
%   then clicks a representative zero point. The zero is computed as the
%   mean of a ±5-sample window around the clicked point.
%
%   INPUTS:
%       Triax         - table loaded from raw .csv experiment file
%       run_index_i   - index of run start (from pick_run_indices)
%       run_index_f   - index of run end   (from pick_run_indices)
%
%   OUTPUT:
%       Szero         - scalar offset (MPa) to subtract from raw differential stress

    % --- Extract time and differential stress signal ---
    t = Triax.Time;
    y = Triax.DifferentialStress;

    % --- Open figure and plot full time series ---
    figure('Name', 'Pick Stress Zero', 'NumberTitle', 'off')
    plot(t, y, 'k', 'LineWidth', 1.5); hold on
    xlabel('Time')
    ylabel('Differential Stress (MPa)')
    title({'Zoom into BASELINE region, press ENTER', ...
           'Then click one point for zero'})
    grid on

    % --- Mark run boundaries for spatial reference ---
    % Green = start of shearing, Red = end of shearing
    % Zero should be picked BEFORE the green line (pre-run baseline)
    xline(t(run_index_i), 'g--', 'LineWidth', 1, ...
        'Label', 'Start of Shearing', ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'bottom');
    xline(t(run_index_f), 'r--', 'LineWidth', 1, ...
        'Label', 'End of Shearing', ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'top');
    legend('Differential Stress (MPa)')

    % --- Zoom step: let user navigate to baseline region ---
    zoom on
    disp('Zoom into baseline region, then press ENTER')
    pause
    zoom off

    % --- Pick step: user clicks one representative baseline point ---
    disp('Click baseline point')
    [x, ~] = ginput(1);

    % --- Convert clicked x-coordinate (time) to nearest sample index ---
    [~, idx] = min(abs(t - x));

    % --- Compute zero as mean of ±5-sample window around clicked point ---
    % Window of 5 is consistent across all pick_ functions.
    % Keeps the zero stable against single-sample noise.
    win = 5;
    i1  = max(1, idx - win);
    i2  = min(length(y), idx + win);
    Szero = mean(y(i1:i2), 'omitnan');

    % --- Visual confirmation: mark selected zero location ---
    xline(t(idx), 'b--', 'LineWidth', 2, 'Label', 'Selected Zero')

    % --- Print to console for log/record ---
    fprintf('Differential stress zero: %.3f MPa\n', Szero)

end