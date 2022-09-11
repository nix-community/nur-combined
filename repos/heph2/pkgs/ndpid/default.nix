{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, pkg-config
, libtool
, cmake
, binutils
, gcc
, git
, libcap
, libgpg-error
, libjson
, zlib
, netcat-openbsd
, tree
, lcov
, callPackage
, libpcap }:
  
let
  ndpi-dev = callPackage ../ndpi/default.nix {};
in
stdenv.mkDerivation rec {
  pname = "ndpid";
  version = "1.5";
  
  src = fetchFromGitHub {
    owner = "utoni";
    repo = "nDPId";
    rev = version;
    sha256 = "sha256-TOlIgW9kHFess459qpVJNqUbk7LgarPk3reYfQUJmSc=";
  };

  nativeBuildInputs = [
    autoconf automake pkg-config libtool
  ];
  
  buildInputs = [
    cmake
    binutils
    gcc
    git
    libcap
    libgpg-error
    libjson
    zlib
    netcat-openbsd
    tree
    lcov
    ndpi-dev
    libpcap
  ];
  
  meta = with lib; {
    description = "An nDPI daemon";
    longDescription = ''
      nDPI Daemons for capture, process and classify network traffic.
    '';
    homepage = "https://github.com/utoni/nDPId";
    license = with licenses; [ lgpl3Plus ];
    maintainers = with maintainers; [ heph2 ];
    mainProgram = "nDPId";
    platforms = with platforms; unix;
  };
}
