{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libarchive,
  cadical,
  python3,
}:
stdenv.mkDerivation (
  (import ./shared.nix {
    inherit lib;
    inherit fetchFromGitHub;
    inherit libarchive;
    inherit cadical;
  })
  // {
    nativeBuildInputs = [
      cmake
      (python3.withPackages (python-pkgs: with python-pkgs; [ pybind11 ]))
    ];

    meta.mainProgram = "gbdc";
  }
)
