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
  version = "2020-03-25";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "2d35d15cc90d5afbb87e8079bd336820cd87efe1";
    sha256 = "1np312kb9nyq8a22537xf7xri5qvw5rdr4f9b0hv08xdfwhy9qzd";
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
