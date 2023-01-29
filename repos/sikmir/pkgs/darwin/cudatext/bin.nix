{ lib, stdenv, fetchurl, undmg, cudatext }:

stdenv.mkDerivation (finalAttrs: {
  pname = "cudatext-bin";
  version = "1.182.0.1";

  src = fetchurl {
    url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-amd64-${finalAttrs.version}.dmg";
    hash = "sha256-z3Z6TmmbTx+9EYnRdbmqVP8dDl+uDOwEsIFbZ/T5Hq0=";
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
})
