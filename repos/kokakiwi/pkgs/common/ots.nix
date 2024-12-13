{ fetchFromGitHub }:
rec {
  version = "1.15.1";

  src = fetchFromGitHub {
    owner = "Luzifer";
    repo = "ots";
    rev = "v${version}";
    hash = "sha256-MIqVNiogzDFw1RB0MY0A0YBns2Llxze1OueXUIjnkpw=";
  };
}
