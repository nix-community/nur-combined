{ lib
, stdenv
, fetchurl
, pkg-config
, bison
, flex
, asciidoc
, libxslt
, findXMLCatalogs
, docbook_xml_dtd_45
, docbook_xsl
, libmnl
, libnftnl-fullcone
, libpcap
, gmp
, jansson
, libedit
, autoreconfHook
, withDebugSymbols ? false
, withPython ? false
, python3
, withXtables ? true
, iptables
}:

stdenv.mkDerivation rec {
  version = "1.0.5";
  pname = "nftables";

  src = fetchurl {
    url = "https://netfilter.org/projects/nftables/files/${pname}-${version}.tar.bz2";
    hash = "sha256-jRtLGDk69DaY0QuqJdK5tjl5ab7srHgWw13QcU5N5Qo=";
  };
  patches = [
    (fetchurl {
      url = "https://github.com/fullcone-nat-nftables/nftables-1.0.5-with-fullcone/commit/9c783d9b4a67fb6c8ff760634f2c7268ceb6e18f.diff";
      sha256 = "sha256-Y44mzD9dlHX+uHrYXMMRmrjU9gklZbn35281d3YWrKI=";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    bison
    flex
    asciidoc
    docbook_xml_dtd_45
    docbook_xsl
    findXMLCatalogs
    libxslt
  ];

  buildInputs = [
    libmnl
    libnftnl-fullcone
    libpcap
    gmp
    jansson
    libedit
  ] ++ lib.optional withXtables iptables
  ++ lib.optional withPython python3;

  configureFlags = [
    "--with-json"
    "--with-cli=editline"
  ] ++ lib.optional (!withDebugSymbols) "--disable-debug"
  ++ lib.optional (!withPython) "--disable-python"
  ++ lib.optional withPython "--enable-python"
  ++ lib.optional withXtables "--with-xtables";

  enableParallelBuilding = true;

  meta = with lib; {
    description = "The project that aims to replace the existing {ip,ip6,arp,eb}tables framework (with fullcone support)";
    homepage = "https://netfilter.org/projects/nftables/";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ izorkin ajs124 ];
    mainProgram = "nft";
  };
}
