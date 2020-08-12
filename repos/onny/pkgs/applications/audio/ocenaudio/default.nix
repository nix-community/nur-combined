{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "ocenaudio";
  version = "3.7.20";

  src = fetchurl {
    url = "https://www.ocenaudio.com/downloads/index.php/ocenaudio_archlinux.pkg.tar.xz?version=3.7.20";
    sha256 = "1q7wxqc7ngmv93cisqgah5wbnh3k27x8rp1x7j6bqdzs5xsb0bfi";
  };

  installPhase = ''
    install -dm755 "$out/bin"
    install -m755 $src $out/bin/${pname}
  '';

  meta = with stdenv.lib; {
    description = "Cross-platform, easy to use, fast and functional audio editor";
    homepage = "https://www.ocenaudio.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ onny ];
    platforms = platforms.linux;
  };
}
