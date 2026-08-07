# darktable with the native spektrafilm spectral film-simulation module.
#
# This builds the spektrafilm PR branch (a dev snapshot of darktable 5.8.0)
# which adds the spektrafilm IOP as native C:
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
# so they self-match the fork.
{
  lib,
  darktable,
  fetchFromGitHub,
  makeWrapper,
  symlinkJoin,
  spektrafilmDataPack ? null,
  darktableAiModels ? null,
  # Enable darktable's ONNX-based AI features (pulls in onnxruntime + libarchive
  # and the USE_AI cmake path). The spektrafilm PR branch keeps darktable's
  # USE_AI option (src/CMakeLists.txt), so it composes normally. Off by default
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
  # which the resolver is happy to read.
  wrapperArgs =
    lib.optionals wrapDataPack [
      ''--run 'darktable_config_home="''${XDG_CONFIG_HOME:-''${HOME:+$HOME/.config}}"; spektrafilm_packs_dir="$darktable_config_home/darktable/spektrafilm/packs"; spektrafilm_pack_dir="$spektrafilm_packs_dir/${spektrafilmDataPack.lutHash}"; if [ -n "$darktable_config_home" ]; then mkdir -p "$spektrafilm_packs_dir"; if [ -L "$spektrafilm_pack_dir" ] || [ ! -e "$spektrafilm_pack_dir" ]; then ln -sfn ${spektrafilmDataPack} "$spektrafilm_pack_dir"; fi; fi' ''
    ]
    ++ lib.optionals wrapAiModels [
      ''--run 'darktable_data_home="''${XDG_DATA_HOME:-''${HOME:+$HOME/.local/share}}"; darktable_models_dir="$darktable_data_home/darktable/models"; if [ -n "$darktable_data_home" ]; then mkdir -p "$darktable_data_home/darktable"; if [ -L "$darktable_models_dir" ] || [ ! -e "$darktable_models_dir" ]; then ln -sfn ${darktableAiModels} "$darktable_models_dir"; fi; fi' ''
    ];
  base = (darktable.override { inherit withAi; }).overrideAttrs (old: {
    pname = "darktable-spektrafilm";
    # Tracks a moving PR branch head, not a tagged release, so
    # the datestamp keeps the store path honest. Bump it together with src.rev.
    version = "5.8.0-unstable-2026-08-05";

    src = fetchFromGitHub {
      owner = "piratenpanda";
      repo = "darktable";
      # darktable-org/darktable#21534 head (== branch `spektrafilm`), rebased on
      # master 2026-08-04 so it builds standalone. Verify with:
      #   git ls-remote https://github.com/piratenpanda/darktable refs/pull/21534/head
      rev = "37ac235fffc86dc0cb20ad3f4ef5a7f46a1f8384";
      fetchSubmodules = true;
      hash = "sha256-qo0DNzewtQS//myw3FcLydHjARXZ+0pppr5gKjpgVcI=";
    };

    # No local patches: the toggle-helper shim we used to carry is now obsolete —
    # dt_bauhaus_toggle_set{,_default} are declared in src/bauhaus/bauhaus.h
    # upstream and spektrafilm.c includes it, so a local static-inline redefinition
    # would fail to compile.
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
        "darktable with the native spektrafilm spectral film-simulation module (darktable PR 21534)";
      homepage = "https://github.com/darktable-org/darktable/pull/21534";
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
