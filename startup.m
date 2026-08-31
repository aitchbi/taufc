%-set repository paths.
%--------------------------------------------------------------------------
repo_dir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(repo_dir, 'src')));

%-set optional original helper path.
%--------------------------------------------------------------------------
utils_tmp = fullfile(repo_dir, 'src', 'utils', 'utils_tmp');

if exist(utils_tmp, 'dir')

    addpath(genpath(utils_tmp));
end

%-show dependency note.
%--------------------------------------------------------------------------
fprintf('\n.taufc repository paths added.\n');
fprintf('.for hb_* helper functions, add https://github.com/aitchbi/matlab-utils to the MATLAB path.\n');
