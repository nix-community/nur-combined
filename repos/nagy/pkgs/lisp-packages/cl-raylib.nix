{
  sbcl,
  sbclPackages,
  fetchFromGitHub,
  raylib,
}:

sbcl.buildASDFSystem {
  pname = "cl-raylib";
  version = "0.0.2-unstable-2024-07-15";

  src = fetchFromGitHub {
    owner = "longlene";
    repo = "cl-raylib";
    rev = "d2ee2cdee84bf070a684a3ce9bf4a8902db975ec";
    hash = "sha256-X5Yr7tNF9/eR+QAY7Lc2pCQLEsd8IxMEMYOGhYalTGc=";
  };

  lisp = sbcl;
  nativeLibs = [ raylib ];

  lispLibs = with sbclPackages; [
    cffi-libffi
    _3d-vectors
    _3d-matrices
  ];
}
