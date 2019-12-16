{ stdenv, fetchurl, perlPackages }:
with perlPackages;
buildPerlPackage rec {
  pname = "Data-Stag";
  version = "0.14";
  src = fetchurl {
    url = "mirror://cpan/authors/id/C/CM/CMUNGALL/${pname}-${version}.tar.gz";
    sha256 = "4ab122508d2fb86d171a15f4006e5cf896d5facfa65219c0b243a89906258e59";
  };
  propagatedBuildInputs = [ IOString ];
  meta = {
    description = "Structured Tags";
  };
}
