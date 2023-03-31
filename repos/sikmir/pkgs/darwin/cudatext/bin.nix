{ lib, stdenv, fetchurl, undmg, cudatext }:

stdenv.mkDerivation (finalAttrs: {
  pname = "cudatext-bin";
  version = "1.189.0.0";

  src = {
    "aarch64-darwin" = fetchurl {
      url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-aarch64-${finalAttrs.version}.dmg";
      hash = "sha256-bupygHalXA3xtjaLlTvqAC+vYKtf63o9xbPhOb3sMbc=";
    };
    "x86_64-darwin" = fetchurl {
      url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-amd64-${finalAttrs.version}.dmg";
      hash = "sha256-9hOWiSFjR+rzrPXHCy4zZm/K0r8OzT857c/YII9K2FI=";
    };
  }.${stdenv.hostPlatform.system};

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -R *.app $out/Applications
  '';

  meta = with lib; {
    inherit (cudatext.meta) description homepage changelog license;
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
})
