# Spektrafilm film & print data pack for the darktable spektrafilm module.
#
# The darktable spektrafilm IOP reads its spectral LUT + film/paper profiles at
# runtime from a pack directory holding:
#   pack.json, spectra_lut.f32, profiles/*.json
# (see sf_pack_load() / src/common/spektra_fetch.c). darktable can now download
# this pack itself from within the UI, but we bundle it declaratively so it works
# offline and reproducibly, byte-identical to what the download would install.
#
# We mirror the *canonical published pack repository* rather than regenerating
# the pack from the Python `spektrafilm` package. The module's in-UI downloader
# reads it from:
#   https://raw.githubusercontent.com/<repo>/<ref>/manifest.json
#   https://raw.githubusercontent.com/<repo>/<ref>/<base>/{pack.json,spectra_lut.f32,profiles/*}
# (defaults: repo = piratenpanda/darktable-spektrafilm, ref = main). Fetching the
# same repo at a pinned commit guarantees the pack's LUT hash matches what edits
# made against this darktable build record, which regenerating from a possibly
# differently-versioned Python package would not.
#
# The manifest's single default pack, pinned below:
#   lut_id  = irradiance_xy_tc@0.3.3
#   lut_hash = 565f4ec4        (also the spectra_lut.f32 header hash, LE @ byte 28)
#   base    = packs/0.3.3      (subdir in the repo holding the pack files)
#   pack_format = 2            (SFS2 v2 raw float16 — matches the module's reader)
#
# `lutHash` is exposed via passthru so callers can place this at the exact path
# the module scans, ~/.config/darktable/spektrafilm/packs/<lutHash>/ .
{
  lib,
  runCommand,
  fetchFromGitHub,

  # Pinned pack repo. Bump `rev`/`hash` together with `base`/`lutHash` when the
  # published manifest changes (see SPEKTRAFILM-UPGRADE-NOTES.md).
  repoOwner ? "piratenpanda",
  repoName ? "darktable-spektrafilm",
  rev ? "d32583b041ac253226f334379758c9a5830df442",
  hash ? "sha256-WVV/906VYPDoj77cjUVp6RWzuEhRWnuzGY6ypAdjjU4=",
  base ? "packs/0.3.3",
  lutHash ? "565f4ec4",
  spektrafilmVersion ? "0.3.3",
  packFormat ? 2,
}:

let
  repo = fetchFromGitHub {
    owner = repoOwner;
    repo = repoName;
    inherit rev hash;
  };
in
runCommand "spektrafilm-data-pack-${spektrafilmVersion}"
  {
    passthru = {
      inherit lutHash spektrafilmVersion packFormat base;
      packRepo = repo;
      packRev = rev;
    };
    meta = {
      description =
        "Spektrafilm spectral data pack (film + paper profiles) for darktable's spektrafilm module";
      homepage = "https://github.com/${repoOwner}/${repoName}";
      platforms = lib.platforms.all;
    };
  }
  ''
    src="${repo}/${base}"
    if [ ! -f "$src/pack.json" ] || [ ! -f "$src/spectra_lut.f32" ]; then
      echo "pack files not found under ${base} in ${repoOwner}/${repoName}" >&2
      exit 1
    fi

    mkdir -p "$out"
    cp -r "$src"/. "$out"/

    # Sanity: the spectra_lut.f32 header must carry lut_hash 0x${lutHash}.
    # Header is: magic 'SFS2' (4) | int32 version (4) | int32 dims[3] (12) |
    # int32 dtype (4) | uint32 lut_hash (4) | int32 id_len ..., so the LUT hash
    # is the little-endian uint32 at byte offset 24. Guards against a pack rev /
    # lutHash mismatch that would leave the module unable to resolve this pack.
    magic=$(head -c 4 "$out/spectra_lut.f32")
    if [ "$magic" != "SFS2" ]; then
      echo "unexpected spectra_lut.f32 magic: '$magic' (expected SFS2)" >&2
      exit 1
    fi
    got=$(od -An -tx1 -j24 -N4 "$out/spectra_lut.f32" | tr -d ' \n')
    # bytes are little-endian; reverse to compare against the big-endian hex hash
    want="${lutHash}"
    rev_want="''${want:6:2}''${want:4:2}''${want:2:2}''${want:0:2}"
    if [ "$got" != "$rev_want" ]; then
      echo "spectra_lut.f32 hash mismatch: header=$got expected(LE)=$rev_want for lutHash=${lutHash}" >&2
      exit 1
    fi
  ''
