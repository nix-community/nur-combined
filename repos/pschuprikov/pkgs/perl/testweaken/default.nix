{ stdenv, fetchurl, perlPackages }:
with perlPackages;
buildPerlPackage {
  pname = "Test-Weaken";
  version = "3.022000";
  src = fetchurl {
    url = "mirror://cpan/authors/id/K/KR/KRYDE/Test-Weaken-3.022000.tar.gz";
    sha256 = "2631a87121310262e0e96107a6fa0ed69487b7701520773bee5fa9accc295f5b";
  };
  meta = {
    description = "Test that freed memory objects were, indeed, freed";
    license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
  };
}
