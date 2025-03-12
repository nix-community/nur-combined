{ stdenv, lib, fetchFromGitHub, gsl, zlib }:

stdenv.mkDerivation rec {
  version = "0.3.2r109"; 
  name = "fineRADstructure-${version}";

  src = fetchFromGitHub {
    owner = "millanek";
    repo = "fineRADstructure";
    rev = "v.${version}";
    sha256 = "0lyay9d3y859w6vh6j7q7w6qcpgscrms892d3rl3bhy0fzjpzamd";
  };

  buildInputs = [ gsl zlib ];

  meta = {
     description = "Population structure inference from RAD-seq data";
     homepage = https://www.milan-malinsky.org/fineradstructure;
     license = with lib.licenses; [ cc-by-nd-30 ];
     maintainers = with lib.maintainers; [ bzizou ];
     platforms = lib.platforms.linux;
  };
}

