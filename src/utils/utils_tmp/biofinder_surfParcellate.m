function param = biofinder_surfParcellate(sess_fs, WhichAtlas, dirs, varargin)

d = inputParser;

addParameter(d,'parallel_nowhere', false);

addParameter(d,'JustGetFilenames', false);

parse(d,varargin{:});

opts = d.Results;

d_fs_subjs = biofinder_getFsDirs(sess_fs, dirs);

param = struct;

param.ID = sess_fs;

param.WhichAtlas = WhichAtlas;

param.dir_freesurfer = dirs.freesurfer;

param.dir_fsaverage_hb = dirs.fsaverage_hb;

param.dir_hbfssh = dirs.hbfssh;

param.dir_subjs = d_fs_subjs;

param.parallel_nowhere = opts.parallel_nowhere;

param.OverWriteExistingRois = false;

param.JustGetRoisName = opts.JustGetFilenames;

param = hb_corticalparc(param, 'JustGetSurfaceParcellation', true);
end