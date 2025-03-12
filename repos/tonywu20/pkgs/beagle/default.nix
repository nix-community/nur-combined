{ lib, stdenv, fetchFromGitHub, autoconf, automake, pkg-config, libtool, openjdk }:
#{ stdenv, fetchFromGitHub, autoconf, automake, pkg-config, libtool, openjdk, ocl-icd, intel-ocl, opencl-headers }:

stdenv.mkDerivation rec {
  version = "3.1.2"; 
  name = "beagle-${version}";

  src = fetchFromGitHub {
    owner = "beagle-dev";
    repo = "beagle-lib";
    rev = "v${version}";
    sha256 = "06r3068y832y0b2pc7kdswvs65i5809ampmsb8mrrw6nb338dd9j";
  };

 nativeBuildInputs = [ autoconf automake pkg-config libtool ];
 buildInputs = [ openjdk ];
 # nativeBuildInputs = [ autoconf automake pkg-config libtool opencl-headers ];
 # buildInputs = [ intel-ocl ocl-icd openjdk ];

  preConfigure = ''
    ./autogen.sh   
  '';              

#  configureFlags = [ "--with-cuda=${cudatoolkit}" "--with-opencl=${intel-ocl}" ];
#   configureFlags = [ "--with-opencl=${intel-ocl}" ];

  meta = {
     description = "high-performance library that can perform the core calculations at the heart of most Bayesian and Maximum Likelihood phylogenetics packages";
     homepage = https://github.com/beagle-dev/beagle-lib;
     license = with lib.licenses; [ gpl2 ];
     maintainers = with lib.maintainers; [ bzizou ];
  };
}

