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
  version = "2020-03-17";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "d649b50a38e199ac7b6da644cd6c338c798118b5";
    sha256 = "093q2dj2kanb1fbm943bs7r0ifjdgi16v3vj48di7vgzsx7iz7sa";
  };

  makeWrapperArgs = [
    "--prefix" "PATH" ":" (lib.makeBinPath [ nix nix-prefetch ])
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
