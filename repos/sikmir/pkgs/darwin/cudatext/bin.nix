{ lib, stdenv, fetchurl, undmg, cudatext }:

stdenv.mkDerivation rec {
  pname = "cudatext-bin";
  version = "1.176.0.0";

  src = fetchurl {
    url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-amd64-${version}.dmg";
    hash = "sha256-w5hAxkqopNMzeIQFvCBn8+50CtOB15PGjtAzPBuL3MI=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -R *.app $out/Applications
  '';

  meta = with lib; {
    inherit (cudatext.meta) description homepage changelog license;
    platforms = [ "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
}
