{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  bison,
  flex,
  asciidoc,
  libxslt,
  findXMLCatalogs,
  docbook_xml_dtd_45,
  docbook_xsl,
  libmnl,
  libnftnl-fullcone,
  libpcap,
  gmp,
  jansson,
  autoreconfHook,
  withDebugSymbols ? false,
  withCli ? true,
  libedit,
  withPython ? false,
  python3,
  withXtables ? true,
  iptables,
  nixosTests,
}:

stdenv.mkDerivation rec {
  version = "1.0.9";
  pname = "nftables";

  src = fetchurl {
    url = "https://netfilter.org/projects/nftables/files/${pname}-${version}.tar.xz";
    hash = "sha256-o8MEzZugYSOe4EdPmvuTipu5nYm5YCRvZvDDoKheFM0=";
  };
  patches = [
    (fetchurl {
      url = "https://github.com/wongsyrone/lede-1/raw/3ed79cee6f4981b841ce1618e4f5b90e0d0b260d/package/network/utils/nftables/patches/999-01-nftables-add-fullcone-expression-support.patch";
      hash = "sha256-4C/kiaLxxDGRH6V0wQCUk0ZIEKTKADd6KRv8U9lb6fU=";
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

  buildInputs =
    [
      libmnl
      libnftnl-fullcone
      libpcap
      gmp
      jansson
    ]
    ++ lib.optional withCli libedit
    ++ lib.optional withXtables iptables
    ++ lib.optionals withPython [
      python3
      python3.pkgs.setuptools
    ];

  configureFlags =
    [
      "--with-json"
      (lib.withFeatureAs withCli "cli" "editline")
    ]
    ++ lib.optional (!withDebugSymbols) "--disable-debug"
    ++ lib.optional (!withPython) "--disable-python"
    ++ lib.optional withPython "--enable-python"
    ++ lib.optional withXtables "--with-xtables";

  enableParallelBuilding = true;

  meta = with lib; {
    description = "The project that aims to replace the existing {ip,ip6,arp,eb}tables framework (with fullcone support)";
    homepage = "https://netfilter.org/projects/nftables/";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [
      izorkin
      ajs124
    ];
    mainProgram = "nft";
  };
}
