{ lispPackages_new, fetchFromGitHub, raylib }:

lispPackages_new.build-asdf-system {
  pname = "cl-raylib";
  version = "unstable-2022-08-24";
  src = fetchFromGitHub {
    owner = "longlene";
    repo = "cl-raylib";
    rev = "8bf7ee09e46dc5724a440800a28352ec7fe64a5a";
    sha256 = "1xx86ydns3gd0ynx47ajfyqmg1iki0182ahbjw69vcck55dhxc9g";
  };
  lisp = lispPackages_new.sbcl;
  nativeLibs = [ raylib ];
  lispLibs = with lispPackages_new.sbclPackages; [
    cffi-libffi
    _3d-vectors
    _3d-matrices
  ];
}
