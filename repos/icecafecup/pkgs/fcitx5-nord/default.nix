{ stdenv, lib, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "fcitx5";
  version = "bdaa8fb723b8d0b22f237c9a60195c5f9c9d74d1";
  src = fetchurl {
    url = "https://github.com/tonyfettes/fcitx5-nord/archive/${version}/fcitx5-nord-${version}.tar.gz";
    sha256 = "sha256-8c1gbda/BsyoCsTkLWxjo9zdWRsm2Siycr7+buRBAmM=";
  };

  installPhase = ''
    mkdir -p $out/share/fcitx5/themes
    cp -r Nord-Dark Nord-Light $out/share/fcitx5/themes/
  '';

  meta = with lib; {
    description = "Fcitx5 theme based on Nord color";
    homepage = "https://github.com/tonyfettes/fcitx5-nord";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
