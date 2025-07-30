{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libarchive,
  cadical,
  python3,
}:
let
  shared = import ./shared.nix {
    inherit lib;
    inherit fetchFromGitHub;
    inherit libarchive;
    inherit cadical;
  };
in
stdenv.mkDerivation (
  shared
  // {
    nativeBuildInputs = [
      cmake
      (python3.withPackages (python-pkgs: with python-pkgs; [ pybind11 ]))
    ];

    meta = shared.meta // {
      mainProgram = "gbdc";
      description = "Instance Identification, Feature Extraction, and Problem Transformation. The executable tool only.";
    };
  }
)
