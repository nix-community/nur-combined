# darktable with the native spektrafilm spectral film-simulation module.
#
# This builds darktable master (a dev snapshot of the unreleased 5.8.0), which
# since 2026-09-05 carries the spektrafilm IOP natively as C:
#   src/iop/spektrafilm.c, src/common/spektra_{core,sim}.{c,h},
#   data/kernels/spektrafilm.cl (OpenCL path).
# Unlike the ART spektrafilm integration in this repo, this module is
# self-contained C and does NOT depend on the spektrafilm Python package at
# build or runtime — it only reads a data pack at runtime (see data-pack.nix).
#
# The expensive native build is an overrideAttrs on nixpkgs' darktable so we
# inherit the full dependency set, cmake flags and GTK wrapping. Runtime data and
# model links are added in a separate symlinkJoin wrapper so those can change
# without rebuilding darktable itself. No release channel ships 5.8.0 yet, so the
# caller bases this on nixpkgs-unstable (darktable 5.6.0) for the closest
# dependency match. LibRaw/RawSpeed come in as git submodules (fetchSubmodules)
# so they self-match the pinned master revision.
{
  lib,
  darktable,
  fetchFromGitHub,
  makeWrapper,
  symlinkJoin,
  spektrafilmDataPack ? null,
  darktableAiModels ? null,
  # Enable darktable's ONNX-based AI features (pulls in onnxruntime + libarchive
  # and the USE_AI cmake path). Off by default
  # to match nixpkgs; flip with `.override { withAi = true; }`.
  withAi ? false,
}:

let
  wrapDataPack = spektrafilmDataPack != null;
  wrapAiModels = withAi && darktableAiModels != null;
  # Link the pack into darktable's *download-cache* layout, packs/<lut_hash>/,
  # rather than the top-level spektrafilm/ dir. The module resolves either
  # (src/common/spektra_fetch.c), but linking only the hashed leaf keeps
  # spektrafilm/ itself a normal writable dir, so darktable's own in-UI pack
  # download still works for other tables. The leaf is a read-only store symlink,
  # which the resolver is happy to read. Since 2026-08 the module resolves packs
  # under g_get_user_data_dir() (~/.local/share), no longer the config dir —
  # same base dir as the AI models below.
  wrapperArgs =
    lib.optionals wrapDataPack [
      ''--run 'darktable_data_home="''${XDG_DATA_HOME:-''${HOME:+$HOME/.local/share}}"; spektrafilm_packs_dir="$darktable_data_home/darktable/spektrafilm/packs"; spektrafilm_pack_dir="$spektrafilm_packs_dir/${spektrafilmDataPack.lutHash}"; if [ -n "$darktable_data_home" ]; then mkdir -p "$spektrafilm_packs_dir"; if [ -L "$spektrafilm_pack_dir" ] || [ ! -e "$spektrafilm_pack_dir" ]; then ln -sfn ${spektrafilmDataPack} "$spektrafilm_pack_dir"; fi; fi' ''
    ]
    ++ lib.optionals wrapAiModels [
      ''--run 'darktable_data_home="''${XDG_DATA_HOME:-''${HOME:+$HOME/.local/share}}"; darktable_models_dir="$darktable_data_home/darktable/models"; if [ -n "$darktable_data_home" ]; then mkdir -p "$darktable_data_home/darktable"; if [ -L "$darktable_models_dir" ] || [ ! -e "$darktable_models_dir" ]; then ln -sfn ${darktableAiModels} "$darktable_models_dir"; fi; fi' ''
    ];
  base = (darktable.override { inherit withAi; }).overrideAttrs (old: {
    pname = "darktable-spektrafilm";
    # Tracks a moving master head, not a tagged release, so
    # the datestamp keeps the store path honest. Bump it together with src.rev.
    version = "5.8.0-unstable-2026-09-09";

    src = fetchFromGitHub {
      owner = "darktable-org";
      repo = "darktable";
      # Upstream master. PR #21967 (the spektrafilm module) was MERGED into
      # darktable master on 2026-09-05 as d81ccfe23b, so there is no longer a
      # fork to track: src/iop/spektrafilm.c, src/common/spektra_*.{c,h} and
      # data/kernels/spektrafilm.cl all live upstream now.
      #
      # Following master rather than a tag is deliberate — 5.8.0 is unreleased,
      # and the piratenpanda snapshot we used to pin (merge-base 2026-09-01) sits
      # inside the performance regression window of darktable issue #22104.
      # Master carries the fixes for it: #22201 (per-module rendered mask cache,
      # ~75.5ms -> ~12ms; the "showing a mask hangs" bug), #22187 (keep the scharr
      # detail mask across synch_all), #22148 + #22171 (pipe responsiveness).
      #
      # Bump `rev`, `hash` and `version` together. Verify with:
      #   git ls-remote https://github.com/darktable-org/darktable refs/heads/master
      rev = "a1257a7c559b74059e55263a58d63a8085cf4f01";
      fetchSubmodules = true;
      hash = "sha256-m77vrG/VnW8UkgEZfT+kgIsfDlxlrADr5ZFcNxoU0kc=";
    };

    # No local patches here: the toggle-helper shim we used to carry is now
    # obsolete — dt_bauhaus_toggle_set{,_default} are declared in
    # src/bauhaus/bauhaus.h upstream and spektrafilm.c includes it, so a local
    # static-inline redefinition would fail to compile. (Consumers may still add
    # their own via overrideAttrs; nix-configs layers two on top of basePackage.)
    patches = (old.patches or [ ]);

    # fetchFromGitHub strips .git, so darktable's `git describe` version detection
    # would fall back to "unknown-version". Feed the real version to CMake instead
    # (CMakeLists calls generate_version_gen_c(${PROJECT_VERSION} ...) when set),
    # so the binary and DB-schema logic report 5.8.0.
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      "-DPROJECT_VERSION=5.8.0"
    ];

    postFixup = old.postFixup or "";

    # The base derivation greps `darktable --version` for the nix `version`
    # string; our datestamped version won't appear there, so skip the check.
    doInstallCheck = false;

    meta = (old.meta or { }) // {
      description =
        "darktable (master snapshot) with the native spektrafilm spectral film-simulation module";
      homepage = "https://github.com/darktable-org/darktable";
      mainProgram = "darktable";
    };
  });
in
if wrapperArgs == [ ] then
  base
else
  symlinkJoin {
    name = "${base.pname}${lib.optionalString withAi "-ai"}-${base.version}";
    paths = [ base ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/darktable \
        ${lib.concatStringsSep " " wrapperArgs}
    '';
    passthru = (base.passthru or { }) // {
      basePackage = base;
      inherit spektrafilmDataPack darktableAiModels;
    };
    meta = base.meta or { };
  }
