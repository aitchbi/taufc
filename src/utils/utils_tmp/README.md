# original helper utilities

This folder is reserved for selected non-`hb_*` helper utilities from the original manuscript analysis code. These files can be kept with their original names to preserve compatibility with the analysis wrappers while the public code is being modularized.

Functions whose names begin with `hb_*.m` are not duplicated here. They are maintained in the separate MATLAB utilities repository:

https://github.com/aitchbi/matlab-utils

Some BioFINDER-specific environment helpers may be placed under `etc/` as placeholders only, because the original implementations include local directory conventions and internal cohort metadata. Users should adapt these parts to their own data organization.
