# darktable with the native spektrafilm spectral film-simulation module.
#
# This builds the Arecsu/darktable `spektrafilm-draft` branch (a dev snapshot of
# darktable 5.8.0) which adds the spektrafilm IOP as native C:
#   src/iop/spektrafilm.c, src/common/spektra_{core,sim}.{c,h},
#   data/kernels/spektrafilm.cl (OpenCL path).
# Unlike the ART spektrafilm integration in this repo, this module is
# self-contained C and does NOT depend on the spektrafilm Python package at
# build or runtime — it only reads a data pack at runtime (see data-pack.nix).
#
# Packaged as an overrideAttrs on nixpkgs' darktable so we inherit the full
# dependency set, cmake flags and GTK wrapping. No release channel ships 5.8.0
# yet, so the caller bases this on nixpkgs-unstable (darktable 5.6.0) for the
# closest dependency match. LibRaw/RawSpeed come in as git submodules
# (fetchSubmodules) so they self-match the fork.
{
  lib,
  darktable,
  fetchFromGitHub,
  # Enable darktable's ONNX-based AI features (pulls in onnxruntime + libarchive
  # and the USE_AI cmake path). The spektrafilm-draft branch keeps darktable's
  # USE_AI option (src/CMakeLists.txt), so it composes normally. Off by default
  # to match nixpkgs; flip with `.override { withAi = true; }`.
  withAi ? false,
}:

(darktable.override { inherit withAi; }).overrideAttrs (old: {
  pname = "darktable-spektrafilm";
  # Tracks a moving branch head (spektrafilm-draft), not a tagged release, so
  # the datestamp keeps the store path honest. Bump it together with src.rev.
  version = "5.8.0-unstable-2026-07-26";

  src = fetchFromGitHub {
    owner = "Arecsu";
    repo = "darktable";
    rev = "69a1eb660d0610174a1ab6cea5035344aea5583e"; # spektrafilm-draft head
    fetchSubmodules = true;
    hash = "sha256-dGVDTKuuL8BMFXKhepfa6xGixkDVTZxkFJhI6dhVzwQ=";
  };

  # fetchFromGitHub strips .git, so darktable's `git describe` version detection
  # would fall back to "unknown-version". Feed the real version to CMake instead
  # (CMakeLists calls generate_version_gen_c(${PROJECT_VERSION} ...) when set),
  # so the binary and DB-schema logic report 5.8.0.
  cmakeFlags = (old.cmakeFlags or [ ]) ++ [
    "-DPROJECT_VERSION=5.8.0"
  ];

  # The base derivation greps `darktable --version` for the nix `version`
  # string; our datestamped version won't appear there, so skip the check.
  doInstallCheck = false;

  meta = (old.meta or { }) // {
    description =
      "darktable with the native spektrafilm spectral film-simulation module (Arecsu spektrafilm-draft fork)";
    homepage = "https://github.com/Arecsu/darktable/tree/spektrafilm-draft";
  };
})
