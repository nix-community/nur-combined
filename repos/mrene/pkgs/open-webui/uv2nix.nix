# uv2nix and its companions, imported without flake inputs so the package
# stays usable through default.nix (NUR). Importing these sources is IFD.
{ lib, fetchFromGitHub }:
let
  pyproject-nix = import (fetchFromGitHub {
    owner = "pyproject-nix";
    repo = "pyproject.nix";
    rev = "d43f0e74444c1f266c640fc49ce6ce6fb69d33c3";
    hash = "sha256-NUMabnvaL/0Ah9WM9pBMXEp+dQjMSYjezZ/fNjXouLQ=";
  }) { inherit lib; };

  uv2nix = import (fetchFromGitHub {
    owner = "pyproject-nix";
    repo = "uv2nix";
    rev = "c361746c7d630d98b972378290547c8d35542a7a";
    hash = "sha256-3CE1CEwprYlHRlRVkXDkhqec0jjF9Cti7tdk8vVDsCM=";
  }) { inherit lib pyproject-nix; };

  build-systems = import (fetchFromGitHub {
    owner = "pyproject-nix";
    repo = "build-system-pkgs";
    rev = "bdbc5f8dd2ad6136bb2ccecb14f6ec343965b194";
    hash = "sha256-zBKFTg7tEGApNt+CEKI5+WNNomD5MZqYNBr+r6/Bmdg=";
  }) { inherit lib pyproject-nix uv2nix; };
in
{
  inherit pyproject-nix uv2nix build-systems;
}
