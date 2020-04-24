{ buildPerlPackage, fetchurl, perlPackages, lib }:
buildPerlPackage rec {
  pname = "mtop";
  version = "0.6.6";
  src = fetchurl {
    url = "http://downloads.sourceforge.net/project/mtop/mtop/v${version}/mtop-${version}.tar.gz";
    sha256 = "0x0x5300b1j9i0xxk8rsrki0pspyzj2vylhzv8qg3l6j26aw0zrf";
  };
  outputs = ["out"];
  buildInputs = with perlPackages; [ DBI DBDmysql Curses ];

  postInstall = ''
    cd "$out"
    preConfigure || true
  '';

  meta = with lib; {
    description = "MySQL top (monitor and examine slow queries)";
    homepage    = http://mtop.sourceforge.net/;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ { name  = "Marc Prewitt"; email = "mprewitt@chelsea.net"; } ];
    platforms   = platforms.unix;
  };
}
