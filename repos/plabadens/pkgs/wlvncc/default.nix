{
  stdenv,
  lib,
  fetchFromGitHub,
  pkg-config
}:

let
  aml = stdenv.mkDerivation {
    pname = "aml";
    version = "0.2.2";

    src = fetchFromGitHub {
      owner = "any1";
      repo = pname;
      rev = "v${version}";
      hash = "";
    };
  };
in stenv.mkDerivation {
  pname = "wlvncc";
  version = "2022-11-29";
  
  src = fetchFromGitHub {
    owner = "any1";
    repo = pname;
    rev = "64449b249a6e5aa726668c50f2f7f8eb969c3e29";
    hash = "";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    "aml"
  ];


  
}
