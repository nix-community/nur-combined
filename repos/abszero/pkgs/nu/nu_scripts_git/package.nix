{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-03-02";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "2896246ba20a1f2251a0d553983fce067af7eeb2";
      hash = "sha256-OWYv/e4ZKtcSSx3g1CCP3a8JqsDCbCtJIHg88f8rg40=";
    };
  }
)
