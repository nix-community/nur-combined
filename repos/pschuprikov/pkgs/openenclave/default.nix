{ stdenv, fetchFromGitHub, intel-sgx-sdk, intel-sgx-psw, cmake, openssl, dune
, ocaml, curl, python }:
stdenv.mkDerivation rec {
  name = "openenclave-${version}";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "openenclave";
    repo = "openenclave";
    rev = "v${version}";
    sha256 = "KFCbLVj3MMefs91AIKRfnzYxvwojQ8G3ZouW4DrVGmA=";
  };

  cmakeFlags = "-DHAS_QUOTE_PROVIDER=OFF -DENABLE_REFMAN=OFF";

  buildInputs = [ cmake openssl dune ocaml curl python ];

  patches = [ ./0001-fix-build.patch ];

  preConfigure = ''
    patchShebangs 3rdparty tests
  '';

  NIX_CFLAGS_COMPILE = "-I${intel-sgx-sdk}/opt/intel/sgxsdk/include -L${intel-sgx-psw}/usr/lib64 -L${intel-sgx-sdk}/usr/lib64";
}
