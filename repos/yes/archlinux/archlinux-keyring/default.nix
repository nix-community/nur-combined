{ lib
, stdenvNoCC
, fetchzip
, zstd
, rp ? ""
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20221219-1";
  src = fetchzip {
    nativeBuildInputs = [ zstd ];
    stripRoot = false;
    url = "${rp}https://geo.mirror.pkgbuild.com/core/os/x86_64/${pname}-${version}-any.pkg.tar.zst";
    hash = "sha256-Q4eqlaVfRCffPycq3/iFuBHKC13MxxPOlkBe5vBssxA=";
  };
  installPhase = ''
    mkdir -p $out
    cp -r $src/usr/share $out
  '';
  meta = with lib; {
    description = "Arch Linux PGP keyring";
    homepage = "https://gitlab.archlinux.org/archlinux/archlinux-keyring/";
    license = licenses.gpl3Plus;
  };
}