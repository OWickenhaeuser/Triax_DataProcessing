function ALL = load_experiments(exp_list, data_folder)

if nargin < 2 || isempty(data_folder)
    data_folder = pwd;
end

ALL = struct();
ALL.list = exp_list(:)';

for i = 1:length(exp_list)
    expnum = exp_list(i);

    if expnum < 100
        fname = sprintf('UC00%d.mat', expnum);
    else
        fname = sprintf('UC0%d.mat', expnum);
    end

    fullpath = fullfile(data_folder, fname);

    if ~isfile(fullpath)
        warning('Missing file: %s', fullpath);
        continue
    end

    S = load(fullpath, 'expdata');

    if isfield(S, 'expdata')
        fieldname = sprintf('exp%d', expnum);
        ALL.(fieldname) = S.expdata;
    else
        warning('No expdata found in: %s', fullpath);
    end
end

end