{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-05-13";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "018fe3c3134d49504be652a7ace5512291545317";
      hash = "sha256-JUsFHsacED+7eTLAlfBnF9vasIHWIL/POJMCPbC9Baw=";
    };
  }
)
