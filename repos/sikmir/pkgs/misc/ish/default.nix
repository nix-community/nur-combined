{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "ish";
  version = "0.2";

  src = fetchurl {
    url = "mirror://sourceforge/icmpshell/ish-v${version}.tar.gz";
    sha256 = "10jp7l0in91n5prc83ykma14r8wd6gyd1amzfi8jysw1jprc92qb";
  };

  postPatch = ''
    substituteInPlace Makefile --replace "/bin/rm" "rm"
  '';

  makeFlags = [ "linux" ];

  installPhase = ''
    install -Dm755 ish ishd -t $out/bin
  '';

  meta = with lib; {
    description = "ICMP Shell";
    homepage = "http://icmpshell.sourceforge.net";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
