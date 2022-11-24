{ lib
, stdenvNoCC
, fetchzip
, zstd
, rp ? ""
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20221123-1";
  src = fetchzip {
    nativeBuildInputs = [ zstd ];
    url = "${rp}https://geo.mirror.pkgbuild.com/core/os/x86_64/${pname}-${version}-any.pkg.tar.zst";
    hash = "sha256-j0T6CeHUUUoRyhs4vYav3FjHnKtXKi7M6+N4VOuQGzw=";
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