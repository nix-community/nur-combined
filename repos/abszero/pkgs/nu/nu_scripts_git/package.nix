{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-21";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "f5bc4cd7461af51a2faea25b9691d36694147500";
      hash = "sha256-csOlHrWnDXBSDdgK/5YaWFn0Abku6l4mNgqlyywEOS4=";
    };
  }
)
