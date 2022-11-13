{ lib, stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "marta-bin";
  version = "0.8.1";

  src = fetchurl {
    url = "https://updates.marta.sh/release/Marta-${version}.dmg";
    hash = "sha256-DbNkvLCy6q0CN8b4+8oheM4EaaLAQvH3O5zWVYxEyh8=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = with lib; {
    description = "File Manager for macOS";
    homepage = "https://marta.sh/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
