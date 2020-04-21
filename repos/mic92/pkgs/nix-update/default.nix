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
  version = "2020-04-21";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "6f70d713b97dfa3365eb2a5b504b32c4a2600681";
    sha256 = "1336r4427kjc0bj5pf6bncxa1mqa7ccr4mdhdrzxc8y2s12jksnc";
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
