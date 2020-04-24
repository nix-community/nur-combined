{ lib, buildPerlPackage, fetchurl, perlPackages }:
buildPerlPackage rec {
  pname = "note";
  version = "1.3.26";
  src = fetchurl {
    url = "mirror://cpan/authors/id/T/TL/TLINDEN/${pname}-${version}.tar.gz";
    sha256 = "1h645rnb5vpms48fcyzvp7cwwcbf9k5xq49w2bpniyzzgk2brjrq";
  };
  outputs = ["out" "man"];
  propagatedBuildInputs = with perlPackages; [ YAML ];

  meta = with lib; {
    description = "A perl script for maintaining notes";
    homepage    = http://www.daemon.de/NOTE;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ { name  = "T.v.Dein"; email = "tlinden@cpan.org"; } ];
    platforms   = platforms.unix;
  };
}
