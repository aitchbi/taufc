# original helper utilities

this directory (utils_tmp) is reserved mostly for selected non-`hb_*` helper utilities from the original manuscript analysis code. these files arekept with their original names to preserve compatibility with the analysis wrappers while the public code is being modularized.

MATLAB functions whose names begin with `hb_*.m` in the demo and helper scripts are largely not duplicated here; the few remaining ones will also be removed. they are maintained in the separate MATLAB utilities repository:

https://github.com/aitchbi/matlab-utils

some BioFINDER-specific environment helpers areplaced under `etc/` as placeholders only, because the original implementations include local directory conventions and internal cohort metadata that may become to local researchers with access to the BioFINDER data. users should adapt these parts to their own data organization.
