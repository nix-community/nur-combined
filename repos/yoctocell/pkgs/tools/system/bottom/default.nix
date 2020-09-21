{ stdenv
, fetchFromGitHub
, callPackage
, sources
}:
let
  naersk = callPackage sources.naersk { };
in
naersk.buildPackage rec {
  name = "bottom";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "ClementTsang";
    repo = "bottom";
    rev = version;
    sha256 = "15DmcLO3qkrAzRB6a3m7f/t3ZFWPEmEwusJYluQIQW4=";
  };
}
