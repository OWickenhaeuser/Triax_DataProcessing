function [Pp1_P_zero, Pp1_D_zero, Pp2_P_zero, Pp2_D_zero] = ...
        pick_pore_zero(Triax, run_index_i, run_index_f)
% PICK_PORE_ZERO  Interactively select baseline zeros for both pore pressure
%                 transducers (pressure and displacement channels).
%
%   [Pp1_P_zero, Pp1_D_zero, Pp2_P_zero, Pp2_D_zero] = ...
%       pick_pore_zero(Triax, run_index_i, run_index_f)
%
%   Calls pick_one_pore twice — once for Pp1, once for Pp2. Each call
%   opens its own figure and returns a pressure zero and a displacement
%   zero for that transducer.
%
%   INPUTS:
%       Triax         - table loaded from raw .csv experiment file
%       run_index_i   - index of run start (from pick_run_indices)
%       run_index_f   - index of run end   (from pick_run_indices)
%
%   OUTPUTS:
%       Pp1_P_zero    - scalar pressure offset (MPa) for pore transducer 1
%       Pp1_D_zero    - scalar displacement offset for pore transducer 1
%       Pp2_P_zero    - scalar pressure offset (MPa) for pore transducer 2
%       Pp2_D_zero    - scalar displacement offset for pore transducer 2

    [Pp1_P_zero, Pp1_D_zero] = pick_one_pore(Triax, run_index_i, run_index_f, 1);
    [Pp2_P_zero, Pp2_D_zero] = pick_one_pore(Triax, run_index_i, run_index_f, 2);

end

% -------------------------------------------------------
function [P_zero, D_zero] = pick_one_pore(Triax, run_index_i, run_index_f, ppnum)
% PICK_ONE_PORE  Internal helper — picks zero for a single pore pressure transducer.
%
%   [P_zero, D_zero] = pick_one_pore(Triax, run_index_i, run_index_f, ppnum)
%
%   Opens a figure showing both the pressure and displacement channels for
%   the specified transducer. The user zooms into the pre-run baseline,
%   then clicks one representative zero point. Both zeros (pressure and
%   displacement) are computed from the same clicked location, using a
%   ±5-sample window average.
%
%   INPUTS:
%       Triax         - table loaded from raw .csv experiment file
%       run_index_i   - index of run start (from pick_run_indices)
%       run_index_f   - index of run end   (from pick_run_indices)
%       ppnum         - transducer number, 1 or 2
%
%   OUTPUTS:
%       P_zero        - scalar pressure offset (MPa)
%       D_zero        - scalar displacement offset

    % --- Extract time and both channels for this transducer ---
    % Column names are built dynamically so this helper works for Pp1 and Pp2
    t     = Triax.Time;
    P_col = Triax.(['PorePressure',              num2str(ppnum)]);
    D_col = Triax.(['PorePressure', num2str(ppnum), 'Displacement']);

    % --- Open figure and plot both channels together ---
    % Plotting both on the same axes lets the user pick one zero point
    % that is representative for both pressure and displacement
    figure('Name', sprintf('Pick Pore Pressure %d Zeros', ppnum), 'NumberTitle', 'off')
    plot(t, P_col, t, D_col); hold on
    xlabel('Time')
    ylabel('Pore Pressure / Displacement')
    title({sprintf('Pp%d — Zoom into zero region, press ENTER', ppnum), ...
           'Then click zero point'})
    grid on
    legend('Pressure (MPa)', 'Displacement')

    % --- Mark run boundaries for spatial reference ---
    % Zero should be picked BEFORE the green line (pre-run baseline)
    xline(t(run_index_i), 'g--', 'LineWidth', 1, ...
        'Label', 'Start of Shearing', ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'bottom');
    xline(t(run_index_f), 'r--', 'LineWidth', 1, ...
        'Label', 'End of Shearing', ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'top');

    % --- Zoom step: let user navigate to baseline region ---
    zoom on
    disp('Zoom into zero region, then press ENTER')
    pause
    zoom off

    % --- Pick step: user clicks one representative baseline point ---
    disp('Click the zeroing point')
    [x, ~] = ginput(1);

    % --- Convert clicked x-coordinate (time) to nearest sample index ---
    [~, idx] = min(abs(t - x));

    % --- Compute zeros as mean of ±5-sample window around clicked point ---
    % Same single click is used for both pressure and displacement zeros,
    % since both channels should be stable at the same baseline moment.
    % Window of 5 is consistent across all pick_ functions.
    win      = 5;
    get_mean = @(sig) mean(sig(max(1, idx-win) : min(length(sig), idx+win)), 'omitnan');

    P_zero = get_mean(P_col);
    D_zero = get_mean(D_col);

    % --- Visual confirmation: mark selected zero location ---
    xline(t(idx), 'b--', 'LineWidth', 2, 'Label', 'Selected Zero')

    % --- Print to console for log/record ---
    fprintf('Pp%d_P zero: %.3f MPa\n', ppnum, P_zero)
    fprintf('Pp%d_D zero: %.3f\n',     ppnum, D_zero)

end