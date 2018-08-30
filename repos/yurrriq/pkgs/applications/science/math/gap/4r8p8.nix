{ stdenv, fetchurl, m4, gmp }:

let
  baseName = "gap";
  version = "4r8p8";

  pkgVer = "2017_08_20-15_12";
in

stdenv.mkDerivation rec {
  name = "${baseName}-${version}";
  inherit version;

  src = fetchurl {
    url = "https://www.gap-system.org/pub/gap/gap48/tar.gz/${baseName}${version}_${pkgVer}.tar.gz";
    sha256 = "0yqs07shs9k2sh5d69vmphi29s8nlwigyy61bndmn1k4fh9bhdsl";
  };

  configureFlags = [ "--with-gmp=system" ];
  buildInputs = [ m4 gmp ];

  postBuild = ''
    pushd pkg
    bash ../bin/BuildPackages.sh
    popd
  '';

  installPhase = ''
    mkdir -p "$out/bin" "$out/share/gap/"

    cp -r . "$out/share/gap/build-dir"

    sed -e "/GAP_DIR=/aGAP_DIR='$out/share/gap/build-dir/'" -i "$out/share/gap/build-dir/bin/gap.sh"

    ln -s "$out/share/gap/build-dir/bin/gap.sh" "$out/bin"
  '';

  meta = with stdenv.lib; {
    description = "Computational discrete algebra system";
    maintainers = with maintainers;
    [
      raskin
      chrisjefferson
      yurrriq
    ];
    platforms = platforms.all;
    license = licenses.gpl2;
    homepage = https://gap-system.org/;
  };
}
