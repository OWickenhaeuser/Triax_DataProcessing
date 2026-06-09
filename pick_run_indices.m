function [run_index_i, run_index_f] = pick_run_indices(Triax)
% PICK_RUN_INDICES  Interactively select the start and end indices of the
%                   shearing run from the full experiment time series.
%
%   [run_index_i, run_index_f] = pick_run_indices(Triax)
%
%   Opens a figure showing the full differential stress time series.
%   The user zooms into the region of interest, then clicks two points
%   marking the START and END of the shearing run. The function returns
%   the sample indices corresponding to those two points.
%
%   This function is called first — its outputs (run_index_i, run_index_f)
%   are passed to all subsequent pick_ functions to mark run boundaries.
%
%   INPUTS:
%       Triax         - table loaded from raw .csv experiment file
%
%   OUTPUTS:
%       run_index_i   - sample index of run start
%       run_index_f   - sample index of run end

    % --- Extract time and differential stress signal ---
    t = Triax.Time;
    y = Triax.DifferentialStress;

    % --- Open figure and plot full time series ---
    figure('Name', 'Select RUN START/END', 'NumberTitle', 'off')
    plot(t, y, 'k', 'LineWidth', 1.5); hold on
    xlabel('Time')
    ylabel('Differential Stress (MPa)')
    title({'Zoom into run region, press ENTER', ...
           'Then click START and END of shearing run'})
    grid on

    % --- Zoom step: let user navigate to the shearing run region ---
    zoom on
    disp('Zoom to region of interest, then press ENTER')
    pause
    zoom off

    % --- Pick step: user clicks run start then run end ---
    disp('Click START point, then END point')
    [x, ~] = ginput(2);

    % --- Convert clicked x-coordinates (time) to nearest sample indices ---
    [~, run_index_i] = min(abs(t - x(1)));
    [~, run_index_f] = min(abs(t - x(2)));

    % --- Ensure correct order in case user clicked right-to-left ---
    if run_index_i > run_index_f
        [run_index_i, run_index_f] = deal(run_index_f, run_index_i);
    end

    % --- Visual confirmation: mark selected start and end ---
    % Green = start of shearing, Red = end of shearing
    % Convention is consistent across all pick_ functions
    xline(t(run_index_i), 'g--', 'LineWidth', 2, ...
        'Label', 'Run Start', ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'bottom');
    xline(t(run_index_f), 'r--', 'LineWidth', 2, ...
        'Label', 'Run End', ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'top');
    legend('Differential Stress (MPa)', 'Run Start', 'Run End')

    % --- Print to console for log/record ---
    fprintf('Run start index: %d\n', run_index_i)
    fprintf('Run end index  : %d\n', run_index_f)

end