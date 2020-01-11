{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "adminer-${version}";
  version = "4.7.5";

  src = fetchurl {
    url = "https://www.adminer.org/static/download/${version}/${name}.php";
    sha256 = "172kjpn5vmpy86vlla21gy6w5cwn4fyrd9pi45basqw99pd52ww5";
  };

  unpackPhase = ":";

  installPhase = ''
    install -Dm0644 "${src}" \
      "$out/share/adminer/index.php"
  '';

  meta = with stdenv.lib; {
    description = "A full-featured Database management tool written in PHP.";
    homepage = https://www.adminer.org;
    license = licenses.asl20;
  };
}
