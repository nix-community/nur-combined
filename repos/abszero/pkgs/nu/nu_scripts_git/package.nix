{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-04-27";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "32cd1d53649bc024edd65326a5b988cd7bcf4810";
      hash = "sha256-t8OCSDI7MqA9Q9Tv4mjd/yRac2SZvhX2x8rfcbIUT9o=";
    };
  }
)
