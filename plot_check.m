function plot_check(expdata)
% PLOT_CHECK  Generate a suite of diagnostic figures for a processed experiment.
%
%   plot_check(expdata)
%
%   Produces 6 figures covering all major channels. Intended to be called
%   immediately after the main processing script to visually verify zeros,
%   run boundaries, and data quality before saving.
%
%   Figures produced:
%       1. LVDTs (full series)
%       2. Confining pressure — full + run (dual y-axis with stroke)
%       3. Pressures + temperature — effective stress, Pc, Pp, and temperature
%       4. Pore pressure diagnostics — 2x2 panel
%       5. Friction + differential/shear stress vs time
%       6. Friction coefficient vs displacement (run only)
%       7. Radial LVDT
%
%   INPUT:
%       expdata   - struct built by main processing script

    t       = expdata.time_full;
    t_run   = expdata.time_run;
    t_start = t(expdata.runindex.start);
    t_end   = t(expdata.runindex.end);

    expstr = num2str(expdata.expnum);

    %% ---------------------------------------------------------------
    % FIGURE 1: Friction + Stress vs Time (run only)
    % Left axis:  friction coefficient (mu).
    % Right axis: differential stress and shear stress.
    % Useful for correlating frictional behavior with stress state
    % throughout the run, including during holds.
    % ---------------------------------------------------------------
    figure('Name', ['Friction & Stress vs Time - Exp ', expstr], 'NumberTitle', 'off')

    yyaxis left
    plot(expdata.time_run, expdata.friction_corr_run, '-b', 'LineWidth', 2);
    ylabel('\mu');

    yyaxis right
    plot(expdata.time_run, expdata.dstress_run,    '-r',  'LineWidth', 1); hold on
    plot(expdata.time_run, expdata.shear_stress_run, '-k', 'LineWidth', 1);
    ylabel('Stress (MPa)');

    add_run_lines(t_start, t_end);
    xlabel('Time (s)');
    title(['Friction & Stress vs Time - Exp ', expstr]);
    legend('\mu', 'Differential stress', 'Shear stress', 'Location', 'best');
    set(gca, 'FontSize', 16); grid on; box on
    hold off
    
    
    %% ---------------------------------------------------------------
    % FIGURE 2: Confining Pressure
    % ---------------------------------------------------------------
    figure('Name', ['Confining Pressure - Exp ', expstr], 'NumberTitle', 'off')

    subplot(2,1,1)
    yyaxis left
    plot(t, expdata.confining_P_full, 'LineWidth', 1.5); hold on
    yline(expdata.target_Pc, '--');
    add_run_lines(t_start, t_end);
    ylim([0 max(expdata.confining_P_full+5)]);
    ylabel('Pressure (MPa)');
    title('Confining Pressure (Full)');
    yyaxis right
    plot(t, expdata.confining_D_full, 'LineWidth', 1.5);
    ylabel('Stroke');
    set(gca, 'FontSize', 16); grid on; box on

    subplot(2,1,2)
    yyaxis left
    plot(expdata.time_run, expdata.confining_P_run, 'LineWidth', 1.5); hold on
    yline(expdata.target_Pc, '--');
    ylabel('Pressure (MPa)');
    title('Confining Pressure (Run)');
    yyaxis right
    plot(expdata.time_run, expdata.confining_D_run, 'LineWidth', 1.5);
    ylabel('Stroke');
    set(gca, 'FontSize', 16); grid on; box on
    hold off

    sgtitle(['Confining Pressure - Exp ', expstr])

    %% ---------------------------------------------------------------
    % FIGURE 3: Pressures + Temperature
    % Left axis: effective stress, confining, mean pore pressure.
    % Right axis: temperature.
    % Note: MATLAB supports only two yyaxis sides; temperature shares the
    % right axis. Target and run-mean lines are on the left axis.
    % ---------------------------------------------------------------
    figure('Name', ['Pressures & Temperature - Exp ', expstr], 'NumberTitle', 'off')

    yyaxis left
    plot(t, expdata.effective_stress_full, '-b',  'LineWidth', 2); hold on
    yline(expdata.target_eff,                '--b', 'LineWidth', 1);
    yline(expdata.effective_stress_mean_run, ':b',  'LineWidth', 2);
    plot(t, expdata.confining_P_full,        '-g',  'LineWidth', 1.5);
    plot(t, expdata.Pp_mean_full,            '-k',  'LineWidth', 1.5);
    ylabel('Pressure (MPa)');

    yyaxis right
    plot(t, expdata.temp_full, 'r', 'LineWidth', 1.5);
    yline(expdata.target_t, '--r', 'LineWidth', 1);
    ylabel('Temperature (°C)');

    add_run_lines(t_start, t_end);
    xlabel('Time (s)');
    title(['Pressures & Temperature - Exp ', expstr]);
    legend('Effective stress', 'Target \sigma_{eff}', 'Mean \sigma_{eff} (run)', ...
           'Confining', 'Pore mean', 'Temperature', 'Target T', ...
           'Location', 'best');
    set(gca, 'FontSize', 16); grid on; box on
    hold off

    %% ---------------------------------------------------------------
    % FIGURE 4: Pore Pressure Diagnostics (2x2)
    % ---------------------------------------------------------------
    figure('Name', ['Pore Pressure Diagnostics - Exp ', expstr], 'NumberTitle', 'off')

    subplot(2,2,1)
    plot(t, expdata.pp1_P_full,   'LineWidth', 1.5); hold on
    plot(t, expdata.pp2_P_full,   'LineWidth', 1.5);
    plot(t, expdata.Pp_mean_full, 'k', 'LineWidth', 2);
    yline(expdata.target_Pp, '--', 'LineWidth', 1.5);
    add_run_lines(t_start, t_end);
    ylim([0 max(expdata.Pp_mean_full)+3]);
    xlabel('Time (s)'); ylabel('Pressure (MPa)');
    title('Pore Pressures');
    legend('Pp1', 'Pp2', 'Mean', 'Target', 'Location', 'best');
    set(gca, 'FontSize', 14); grid on; box on
    hold off

    subplot(2,2,2)
    plot(t, expdata.pp1_D_full, 'LineWidth', 1.5); hold on
    plot(t, expdata.pp2_D_full, 'LineWidth', 1.5);
    add_run_lines(t_start, t_end);
    ylim([0 max(expdata.pp2_D_full)+3]);
    xlabel('Time (s)'); ylabel('Displacement (mm)');
    title('Pore Pressure Displacements');
    legend('Pp1 D', 'Pp2 D', 'Location', 'best');
    set(gca, 'FontSize', 14); grid on; box on
    hold off

    subplot(2,2,3)
    yyaxis left
    plot(t, expdata.pp1_P_full, 'LineWidth', 1.5); hold on
    ylim([0 max(expdata.pp1_P_full)+3]);
    ylabel('Pressure (MPa)');
    yyaxis right
    plot(t, expdata.pp1_D_full, '--', 'LineWidth', 1.5);
    ylabel('Displacement (mm)');
    add_run_lines(t_start, t_end);
    xlabel('Time (s)');
    title('Pp1: Pressure & Displacement');
    legend('Pp1 P', 'Pp1 D', 'Location', 'best');
    set(gca, 'FontSize', 14); grid on; box on
    hold off

    subplot(2,2,4)
    yyaxis left
    plot(t, expdata.pp2_P_full, 'LineWidth', 1.5); hold on
    ylim([0 max(expdata.pp2_P_full)+3]);
    ylabel('Pressure (MPa)');
    yyaxis right
    plot(t, expdata.pp2_D_full, '--', 'LineWidth', 1.5);
    ylabel('Displacement (mm)');
    add_run_lines(t_start, t_end);
    xlabel('Time (s)');
    title('Pp2: Pressure & Displacement');
    legend('Pp2 P', 'Pp2 D', 'Location', 'best');
    set(gca, 'FontSize', 14); grid on; box on
    hold off

    sgtitle(['Pore Pressure Diagnostics - Exp ', expstr])

    %% ---------------------------------------------------------------
    % FIGURE 5: Lateral LVDTs
    % ---------------------------------------------------------------
    figure('Name', ['LVDTs - Exp ', expstr], 'NumberTitle', 'off')
    plot(t, expdata.LVDT1_full, 'LineWidth', 1.5); hold on
    plot(t, expdata.LVDT2_full, 'LineWidth', 1.5);
    plot(t, expdata.LVDTm_full, 'LineWidth', 1.5);
    add_run_lines(t_start, t_end);
    legend('LVDT 1', 'LVDT 2', 'LVDT mean', 'Location', 'northwest');
    ylabel('Displacement (mm)');
    xlabel('Time (s)');
    title(['LVDTs - Exp ', expstr]);
    set(gca, 'FontSize', 16); grid on; box on
    hold off

    %% ---------------------------------------------------------------
    % FIGURE 6: Radial LVDT
    % ---------------------------------------------------------------
    figure('Name', ['Radial LVDT - Exp ', expstr], 'NumberTitle', 'off')

    subplot(2,1,1)
    plot(t, expdata.LVDT3_full, 'LineWidth', 1.5); hold on
    add_run_lines(t_start, t_end);
    ylim([0 max(expdata.LVDT3_full+5)]);
    ylabel('Displacement (mm)');
    xlabel('Time (s)');
    title(['Radial LVDT - Exp ', expstr]);
    set(gca, 'FontSize', 16); grid on; box on

    subplot(2,1,2)
    plot(t_run, expdata.LVDT3_run, 'LineWidth', 1.5); hold on
    add_run_lines(t_start, t_end);
    ylabel('Displacement (mm)');
    xlabel('Time (s)');
    set(gca, 'FontSize', 16); grid on; box on
    hold off

end

% ---------------------------------------------------------------
function add_run_lines(t_start, t_end)
    xline(t_start, 'g--', 'LineWidth', 1.5, 'Label', 'Start', ...
          'LabelOrientation', 'horizontal');
    xline(t_end,   'r--', 'LineWidth', 1.5, 'Label', 'End', ...
          'LabelOrientation', 'horizontal');
end