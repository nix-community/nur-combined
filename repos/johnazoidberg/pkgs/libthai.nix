{ stdenv, fetchurl, pkgconfig, libdatrie }:
stdenv.mkDerivation rec {
  name = "libthai-${version}";
  rev = "v${version}";
  version = "0.1.27";

  src = fetchurl {
    url = "https://linux.thai.net/pub/thailinux/software/libthai/libthai-${version}.tar.xz";
    sha256 = "1xpg0cf0wc2gmsx7vvb1azfb4jyr7y68rsvz5l864r8xgcdzln8n";
  };

  buildInputs = [ pkgconfig libdatrie ];

  meta = with stdenv.lib; {
    description = "LibThai aims to ease incorporation of Thai language support in applications";
    license = licenses.gpl3;
    homepage = https://github.com/tlwg/libthai;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

