function store_data(expdata, filename, save_folder, do_clear)
% STORE_DATA  Save processed experiment data to a .mat file.
%
%   store_data(expdata, filename)
%   store_data(expdata, filename, save_folder)
%   store_data(expdata, filename, save_folder, do_clear)
%
%   Saves two things into a single .mat file:
%       1. The full expdata struct, stored under a unique variable name
%          derived from the filename (e.g. 'UC0229_expdata'). This prevents
%          name collisions when multiple experiments are loaded simultaneously.
%       2. Flat RSFit-ready variables (time, disp_LP, friction, eff_stress,
%          index) and experiment metadata at the top level for quick access
%          by RSFit3000 and other downstream tools.
%
%   INPUTS:
%       expdata       - struct built by main processing script
%       filename      - original .csv filename (e.g. 'UC0229.csv');
%                       used to derive the save name and variable name
%       save_folder   - (optional) folder to save into; defaults to pwd
%       do_clear      - (optional) if true, clears non-essential variables
%                       from the base workspace after saving (default: false)
%                       NOTE: uses evalin('base',...) — only reliable when
%                       called from a script, not from inside a function

    %% ----------------------------
    % DEFAULTS
    % ----------------------------

    % Default save location is the current working directory
    if nargin < 3 || isempty(save_folder)
        save_folder = pwd;
    end

    % Default: do not clear workspace after saving
    if nargin < 4
        do_clear = false;
    end

    %% ----------------------------
    % MAKE FOLDER IF NEEDED
    % ----------------------------

    % Create save folder if it doesn't already exist
    if ~exist(save_folder, 'dir')
        mkdir(save_folder);
        fprintf('Created folder: %s\n', save_folder)
    end

    %% ----------------------------
    % BUILD SAVE NAME AND VARIABLE NAME
    % ----------------------------

    % Strip path and extension from filename to get base name (e.g. 'UC0229')
    [~, name] = fileparts(filename);

    % Full path to output .mat file
    save_name = fullfile(save_folder, [name, '.mat']);

    % Unique struct fieldname for expdata (e.g. 'UC0229_expdata')
    % This prevents collisions when multiple experiments are loaded at once
    expdata_varname = [name, '_expdata'];

    %% ----------------------------
    % ASSEMBLE SAVE STRUCT
    % ----------------------------
    % All variables are packed into a single struct and saved with -struct,
    % so they unpack as individual variables in the workspace on load.

    save_struct = struct();

    % --- Full experiment struct (uniquely named per experiment) ---
    save_struct.(expdata_varname) = expdata;

    % --- Flat RSFit-ready variables (expected by RSFit3000 at top level) ---
    save_struct.time       = expdata.rsfit.time;
    save_struct.disp_LP    = expdata.rsfit.disp_LP;
    save_struct.friction   = expdata.rsfit.friction;
    save_struct.eff_stress = expdata.rsfit.eff_stress;
    save_struct.index      = expdata.rsfit.index;   % run start/end indices

    % --- Experiment metadata (duplicated at top level for quick access) ---
    save_struct.expnum     = expdata.expnum;
    save_struct.depth      = expdata.depth;
    save_struct.target_Pc  = expdata.target_Pc;
    save_struct.target_Pp  = expdata.target_Pp;
    save_struct.target_t   = expdata.target_t;
    save_struct.target_eff = expdata.target_eff;
    save_struct.use_pore   = expdata.use_pore;

    %% ----------------------------
    % SAVE
    % ----------------------------

    % -struct unpacks save_struct so each field becomes its own variable on load
    save(save_name, '-struct', 'save_struct');
    fprintf('Saved: %s\n', save_name)

    %% ----------------------------
    % OPTIONAL WORKSPACE CLEAN
    % ----------------------------
    % Clears all base workspace variables except the ones listed in keepVars.
    % Uses evalin('base',...) which only works correctly when store_data is
    % called from a script. Do not rely on this when called from a function.

    if do_clear
        keepVars       = {'expdata', 'filename', 'save_folder', 'do_clear'};
        vars           = evalin('base', 'who');
        vars_to_clear  = setdiff(vars, keepVars);

        for i = 1:length(vars_to_clear)
            evalin('base', ['clear ', vars_to_clear{i}]);
        end

        fprintf('Workspace cleaned — kept: %s\n', strjoin(keepVars, ', '))
    end

end