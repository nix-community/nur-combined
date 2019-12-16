{ stdenv, fetchurl, buildPerlPackage, perlPackages, BioPerl }:
buildPerlPackage {
  pname = "Bio-SearchIO-hmmer";
  version = "1.7.3";
  src = fetchurl {
    url = "mirror://cpan/authors/id/C/CJ/CJFIELDS/Bio-SearchIO-hmmer-1.7.3.tar.gz";
    sha256 = "686152f8ce7c611d27ee35ac002ecc309f6270e289a482993796a23bb5388246";
  };
  buildInputs = with perlPackages; [ TestDeep TestException TestWarn TestDifferences ];
  propagatedBuildInputs = with perlPackages; [ BioPerl IOString ];
  meta = {
    homepage = https://metacpan.org/release/Bio-SearchIO-hmmer;
    description = "A parser for HMMER2 and HMMER3 output (hmmscan, hmmsearch, hmmpfam)";
    license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
  };
}
