{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name =  "powercap-${version}";
  version = "0.2.0";
  

  src = fetchFromGitHub {
    owner = "powercap";
    repo = "powercap";
    rev = "ad05da76ca84d3c5277d932a32d15fd7c709aa7d";
    sha256 = "1xpik0wrg0gk4s03wfjr5sc6p410dpddg9iyrsdgg2lia55d0ajd";
  };

  buildInputs = [ cmake ];

  meta = with lib; {
    homepage = "https://github.com/powercap/powercap";
    description = "C bindings to the Linux Power Capping Framework in sysfs ";
    longDescription = "This project provides the powercap library -- a generic C interface to the Linux power capping framework (sysfs interface). It includes an implementation for
 working with Intel Running Average Power Limit (RAPL).";
    license = licenses.bsd3;
    platforms = platforms.linux;
    broken = true;
  };
}
