{ sbcl, sbclPackages, fetchFromGitHub, raylib }:

sbcl.buildASDFSystem {
  pname = "cl-raylib";
  version = "unstable-2023-10-26";

  src = fetchFromGitHub {
    owner = "longlene";
    repo = "cl-raylib";
    rev = "abdf7de519dfb48382862123619328602a95e03a";
    hash = "sha256-NpZTOUZtfP5w47ltk7S8nQVx4XhiBlSPauvkiwXyW84=";
  };

  lisp = sbcl;
  nativeLibs = [ raylib ];

  lispLibs = with sbclPackages; [ cffi-libffi _3d-vectors _3d-matrices ];
}
