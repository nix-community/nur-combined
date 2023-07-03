{ lispPackages_new, fetchFromGitHub, raylib }:

lispPackages_new.build-asdf-system {
  pname = "cl-raylib";
  version = "unstable-2023-04-17";
  src = fetchFromGitHub {
    owner = "longlene";
    repo = "cl-raylib";
    rev = "134322a238b2825b109164b1dac7f485aa70bc8d";
    hash = "sha256-nVPuv/pFCNA3ukToJiHhGHVNa/+ipYIR4nluskofDXI=";
  };
  lisp = lispPackages_new.sbcl;
  nativeLibs = [ raylib ];
  lispLibs = with lispPackages_new.sbclPackages; [
    cffi-libffi
    _3d-vectors
    _3d-matrices
  ];
}
