{ lib
, stdenvNoCC
, fetchzip
, zstd
, rp ? ""
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20221213-1";
  src = fetchzip {
    nativeBuildInputs = [ zstd ];
    url = "${rp}https://geo.mirror.pkgbuild.com/core/os/x86_64/${pname}-${version}-any.pkg.tar.zst";
    hash = "sha256-QWm593TCG4Pp2ojT22zHXqSdApBi37wtS9d77mGg2g8=";
  };
  installPhase = ''
    mkdir -p $out
    cp -r $src/share $out
  '';
  meta = with lib; {
    description = "Arch Linux PGP keyring";
    homepage = "https://gitlab.archlinux.org/archlinux/archlinux-keyring/";
    license = licenses.gpl3Plus;
  };
}