{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-19";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "161406c2975453afd85e907b0605525ddc79b87f";
      hash = "sha256-nGqlrzb6Lpfh0O5qgnFfcjCxSSNIh01wyjtCzTNhBsw=";
    };
  }
)
