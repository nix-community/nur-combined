{ stdenv, fetchurl, callPackage, gawk }:
stdenv.mkDerivation rec {
  name = "eprover-${version}";
  version = "2.1";

  src = fetchurl {
    url = "https://wwwlehre.dhbw-stuttgart.de/~sschulz/WORK/E_DOWNLOAD/V_${version}/E.tgz";
    sha256 = "1gh99ajmza33f54idhqkdqxp5zh2k06jsf45drihnrzydlqv1n7l";
  };

  buildInputs = [ gawk ];

  meta = with stdenv.lib; {
    description = "E is a theorem prover for full first-order logic with equality";
    license = licenses.gpl2;
    homepage = https://wwwlehre.dhbw-stuttgart.de/~sschulz/E/E.html;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

