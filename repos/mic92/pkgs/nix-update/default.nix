{ buildPythonApplication
, fetchFromGitHub
, glibcLocales
, makeWrapper
, mypy
, nix
, nix-prefetch
, lib
, stdenv
}:

buildPythonApplication rec {
  pname = "nix-update";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "5eb9f161a0d726e08de71d68e424fe56cce4370c";
    sha256 = "0vgxcjib2cl86r92xsmbp0rj9z13i4hw22l5bzh2zzrvjdp42xl2";
  };

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ nix nix-prefetch ])
  ];

  nativeBuildInputs = [ mypy ];

  checkPhase = ''
    mypy nix_update
  '';

  meta = with stdenv.lib; {
    description = "Update nix packages";
    homepage = src.meta.homepage;
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
    platforms = platforms.all;
  };
}
