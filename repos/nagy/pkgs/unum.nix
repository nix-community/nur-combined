{ lib, stdenv, fetchFromGitHub, perl }:

stdenv.mkDerivation rec {
  pname = "unum";
  version = "3.5";

  src = fetchFromGitHub {
    owner = "Fourmilab";
    repo = pname;
    rev = "6ba7be889e0cffcaf3beb250fe6f1ac483e0257b";
    hash = "sha256-qdiFhs8dHXK6lpEdOg3jT1kJuLOuJHjypgbjmVlm60o=";
  };

  buildInputs = [ perl ];

  makeFlags = [ "unum" ];

  installPhase = ''
    runHook preInstall
    patchShebangs unum/unum.pl
    install -Dm555 unum/unum.pl $out/bin/unum
    runHook postInstall
  '';

  meta = with lib; {
    inherit (src.meta) homepage;
    description =
      "Utility for looking up Unicode characters and HTML entities by code, name, block, or description";
  };
}
