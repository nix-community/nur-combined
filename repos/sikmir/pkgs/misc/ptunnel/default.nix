{
  lib,
  stdenv,
  fetchurl,
  libpcap,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ptunnel";
  version = "0.72";

  src = fetchurl {
    url = "https://www.cs.uit.no/~daniels/PingTunnel/PingTunnel-${finalAttrs.version}.tar.gz";
    hash = "sha256-sxj3qn2IkYtiadBUp+JvBPl9iHD0e9Sadsssmcc0B6Q=";
  };

  buildInputs = [ libpcap ];

  makeFlags = [ "prefix=$(out)" ];

  meta = {
    description = "A tool for reliably tunneling TCP connections over ICMP echo request and reply packets";
    homepage = "https://www.cs.uit.no/~daniels/PingTunnel";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
