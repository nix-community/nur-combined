{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-08-25";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "cee236cf46a597b43f36b56ccee5881fc0483c56";
      hash = "sha256-vW8Lz9MQwIT7WKv2ZkVTiq+398p20RszGZhIZ3I2kq8=";
    };
  }
)
