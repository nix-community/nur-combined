{ lib
, stdenvNoCC
, fetchzip
, zstd
, rp ? ""
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20220831-1";
  src = fetchzip {
    nativeBuildInputs = [ zstd ];
    url = "${rp}https://geo.mirror.pkgbuild.com/core/os/x86_64/${pname}-${version}-any.pkg.tar.zst";
    sha256 = "sha256-m/YHTpT1r639KoLQbhs37OJ68IBKlwoRC8j1WNzMINg=";
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