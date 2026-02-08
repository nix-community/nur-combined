{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-02-07";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "270c98442f0b3f5793aeab824fe0fe148d80baf9";
      hash = "sha256-jUMIze6rvRoW+gO4O17D9G86g+77SONitr1P5yMmmd8=";
    };
  }
)
