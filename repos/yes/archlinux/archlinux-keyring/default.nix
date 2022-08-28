{ lib
, stdenvNoCC
, fetchzip
, zstd
, rp ? ""
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20220727-1";
  src = fetchzip {
    nativeBuildInputs = [ zstd ];
    url = "${rp}https://geo.mirror.pkgbuild.com/core/os/x86_64/${pname}-${version}-any.pkg.tar.zst";
    sha256 = "sha256-6Qq9sxGleOmaU9iqn5dlarlYx7hIfFbaT7lJ7U41efU=";
  };
  installPhase = ''
    cp -r $src $out
  '';
  meta = with lib; {
    description = "Arch Linux PGP keyring";
    homepage = "https://gitlab.archlinux.org/archlinux/archlinux-keyring/";
    license = licenses.gpl3Plus;
  };
}