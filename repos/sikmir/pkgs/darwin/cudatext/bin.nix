{ lib, stdenv, fetchurl, undmg, cudatext }:

stdenv.mkDerivation (finalAttrs: {
  pname = "cudatext-bin";
  version = "1.190.1.0";

  src = {
    "aarch64-darwin" = fetchurl {
      url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-aarch64-${finalAttrs.version}.dmg";
      hash = "sha256-Rr1i+dkesQ4T6kFQZyjvMgGYltyf3UMbzrtaMw+6ToQ=";
    };
    "x86_64-darwin" = fetchurl {
      url = "mirror://sourceforge/cudatext/cudatext-macos-cocoa-amd64-${finalAttrs.version}.dmg";
      hash = "sha256-QgiVsiOrSafjlMDv9DXmjyCMR/J/iKw0NRBC3eV6aSw=";
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
