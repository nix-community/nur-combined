{ lib, stdenv, fetchurl, undmg, cudatext }:

stdenv.mkDerivation (finalAttrs: {
  pname = "cudatext-bin";
  version = "1.184.0.0";

  src = fetchurl {
    url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-amd64-${finalAttrs.version}.dmg";
    hash = "sha256-OUoqsc1kRLMe0dHkcwIKEwhxTX8fHzGBaND3PA5dqGM=";
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
