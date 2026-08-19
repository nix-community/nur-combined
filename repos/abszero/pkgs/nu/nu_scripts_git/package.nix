{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-08-19";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "eb43c8c0df920f4fc7f15058939c66ff89be9d61";
      hash = "sha256-GrJYWbvkfLKFJitvyGjybpI7Vc+6HIiMq0xNoT+g2Pc=";
    };
  }
)
