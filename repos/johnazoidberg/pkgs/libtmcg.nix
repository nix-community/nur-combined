{ stdenv, lib, fetchurl, gmp, libgcrypt, libgpgerror }:
stdenv.mkDerivation rec {
  pname = "libtmcg";
  version = "1.3.16";

  src = fetchurl {
    url = "mirror://savannah/libtmcg/libTMCG-${version}.tar.gz";
    sha256 = "17ajlnqd4ig1m8snn6m71qv058c82i5pzd6rn3rgmigc4iahck7y";
  };

  buildInputs = [ gmp libgcrypt libgpgerror ];

  meta = with lib; {
    description = "C++ library for creating secure and fair online card games";
    license = licenses.gpl2;
    homepage = ttps://www.nongnu.org/libtmcg/;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

