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
  version = "2020-03-24";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "c472f6eba3eb4ee11940712b0be7a4d32c704a8f";
    sha256 = "17cjr1mli3x9hqzbs433489z66riffplzx1miy1gpm6iqfna0avy";
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
