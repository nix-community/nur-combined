{ lib, stdenv, fetchurl, zstd }:
let
  pname = "iosvmata-nerd-font";
  version = "1.2.0";
  src = fetchurl {
    url = "https://github.com/N-R-K/Iosvmata/releases/download/v${version}/Iosvmata-v${version}.tar.zst";
    hash = "sha256-Cq/bx+nc5sTHxb4GerpEHDmW7st835bQ6ihTOp20Ei4=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;
  nativeBuildInputs = [ zstd ];
  dontUnpack = true;

  installPhase = ''
    tar xvf ${src}
    mkdir -p $out/share/fonts/truetype
    install --mode=644 ./Iosvmata-v${version}/Nerd/*.ttf $out/share/fonts/truetype
  '';

  meta = with lib; {
    description = "Custom Iosevka build somewhat mimicking PragmataPro";
    homepage = "https://github.com/N-R-K/Iosvmata";
  };
}
