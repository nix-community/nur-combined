{ lib
, stdenvNoCC
, fetchzip
, zstd
, rp ? ""
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20220927-1";
  src = fetchzip {
    nativeBuildInputs = [ zstd ];
    url = "${rp}https://geo.mirror.pkgbuild.com/core/os/x86_64/${pname}-${version}-any.pkg.tar.zst";
    hash = "sha256-1JuGvo0/DwksY1wXEVSUTpYhgoGRQFzR9jOP+BRGWwA=";
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