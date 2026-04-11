{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-04-11";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "cde594832fba2c21370278bcea1932ad449c2f6f";
      hash = "sha256-I2FETue1KqS/3GKovgYblWrFteOepfGLjp4hWWoAZug=";
    };
  }
)
