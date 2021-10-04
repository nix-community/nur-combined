{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "massdns";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "blechschmidt";
    repo = "massdns";
    rev = version;
    sha256 = "1waxc10br1gxk508s8l0559z33y0ab252q7awk5b5wmzbxpv1ay1";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A high-performance DNS stub resolver for bulk lookups and reconnaissance (subdomain enumeration)";
    license = licenses.gpl3;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
