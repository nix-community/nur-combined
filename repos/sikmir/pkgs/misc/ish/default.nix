{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ish";
  version = "0.2";

  src = fetchurl {
    url = "mirror://sourceforge/icmpshell/ish-v${finalAttrs.version}.tar.gz";
    hash = "sha256-C4vE8pWBay9RdL+q0PwzjaNMgqrTD8TyLTYkGwE9V4I=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace-fail "/bin/rm" "rm"
  '';

  makeFlags = [ "linux" ];

  installPhase = ''
    install -Dm755 ish ishd -t $out/bin
  '';

  meta = {
    description = "ICMP Shell";
    homepage = "http://icmpshell.sourceforge.net";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
