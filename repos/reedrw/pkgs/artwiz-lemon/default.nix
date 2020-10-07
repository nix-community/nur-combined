{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "artwiz-lemon";

  src = fetchFromGitHub {
    owner = "cmvnd";
    repo = "fonts";
    rev = "a8730cc3549fa870c23909c168957520ac4532e5";
    sha256 = "1gslyylg8x01m223d4v4fxw1wxljqbbidnfqwjm0hjh5adhai4bz";
  };

  installPhase = ''
    install -D -m644 lemon.bdf "$out/share/fonts/lemon.bdf"
  '';

}

