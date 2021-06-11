{lib, stdenv, fetchFromGitHub, gfortran}:

stdenv.mkDerivation rec {
  pname = "voacapl";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "jawatson";
    repo = "voacapl";
    rev = "v.${version}";
    sha256 = "1b3r3l4s0hcvfxfyz86pifcx7mblccw8jglcz51lc9cqpfr55y9m";
  };

  nativeBuildInputs = [ gfortran ];

  meta = with lib; {
    description = "HF Propagation Prediction and Ionospheric Communications Analysis";
    license     = licenses.cc0;
    homepage    = "http://mcmc-jags.sourceforge.net";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.unix;
  };
}
