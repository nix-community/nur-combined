{ stdenv
, fetchFromGitHub
, cmake
, gcc
, level-zero
, ...
}:

stdenv.mkDerivation {
  pname = "sysmon";
  version = "0.43.3";
  src = fetchFromGitHub ({
    owner = "intel";
    repo = "pti-gpu";
    rev = "66c166ec79f6f18024e54b3581dbcd3c87e09696";
    sha256 = "sha256-pIaUysQc0X2+JYzjwHhUO4l4AEjBNh3fNNv1IR0R3m8=";
  });


  buildInputs = [ cmake gcc level-zero ];

  configurePhase = ''
    cd tools/sysmon
    mkdir -p build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$out ..
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    make install
  '';
}
