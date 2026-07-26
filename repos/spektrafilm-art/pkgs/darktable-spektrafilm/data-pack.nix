# Spektrafilm film & print data pack for the darktable spektrafilm module.
#
# The darktable spektrafilm IOP reads its spectral LUT + film/paper profiles at
# runtime from <darktable config dir>/spektrafilm/ :
#   pack.json, spectra_lut.f32, profiles/*.json
# (see sf_pack_dir() / dt_loc_get_user_config_dir() in src/iop/spektrafilm.c —
# it only looks in the user config dir, never in the install datadir).
#
# That pack is a prebuilt artifact published by the fork author. It is generated
# from the spektrafilm Python package by an exporter (tools/spektrafilm_export_data.py,
# referenced in spektrafilm.c) that is NOT public yet, so we cannot regenerate
# it reproducibly at build time and pin the published zip instead. Revisit this
# (generate from the `spektrafilm` Python package built in this same flake) once
# the exporter is released.
#
# The zip wraps everything in a single spektrafilm/ directory; stripRoot (the
# fetchzip default) drops it so this derivation's out path *is* the pack
# contents (pack.json, spectra_lut.f32, profiles/). Link that out path in as
# ~/.config/darktable/spektrafilm — see the README.
#
# Pinned to a specific dt-spektrafilm-builds commit for reproducibility. When
# bumping the darktable module (darktable-spektrafilm.nix src.rev), re-pin this
# to the matching pack — dt-spektrafilm-builds/last-built.sha records which
# darktable rev the current pack was built against.
{ fetchzip }:

fetchzip {
  name = "spektrafilm-data-pack";
  url = "https://github.com/Arecsu/dt-spektrafilm-builds/raw/332a154e6db3d60911168d4e03829d2468e9b346/spektrafilm-data-pack.zip";
  hash = "sha256-H41ukz2i1pXfATpYFs4E2UGmvSOXjzvofIIDs0dUDOE=";
}
