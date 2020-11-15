{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "scientifica";
  version = "2.1";

  src = fetchurl {
    url = "https://github.com/NerdyPepper/scientifica/releases/download/v${version}/scientifica-v${version}.tar";
    sha256 = "1djsgv6sgfw4kay6wbks3yqgrmbyyxq4i21aqg1hj0w5ww4wwn9i";
  };

  installPhase = ''
    mkdir -p "$out/share/fonts/"
    install -D -m644 ttf/* "$out/share/fonts/"
  '';

  meta = {
    description = "tall, condensed, bitmap font for geeks.";
    homepage = "https://github.com/NerdyPepper/scientifica";
    license = stdenv.lib.licenses.ofl;
  };
}
