{ stdenv, fetchurl, libtmcg, libgcrypt, libgpgerror, gmp, zlib, bzip2 ? null }:
stdenv.mkDerivation rec {
  name = "dkgpg-${version}";
  version = "1.1.0";

  src = fetchurl {
    url = "mirror://savannah/dkgpg/${name}.tar.gz";
    sha256 = "0zqilvsx3xcrjsjhzckp8wpxajadbrnir4nihaj30kbvanpcy864";
  };

  buildInputs = [ libtmcg libgcrypt libgpgerror gmp zlib bzip2 ];

  meta = with stdenv.lib; {
    description = "Distributed Key Generation (DKG) and Threshold Cryptography for OpenPGP";
    license = licenses.gpl2;
    homepage = https://www.nongnu.org/dkgpg/;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

