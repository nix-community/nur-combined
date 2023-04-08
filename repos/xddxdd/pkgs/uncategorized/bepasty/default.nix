{
  lib,
  sources,
  python3Packages,
  xstatic-asciinema-player,
  xstatic-font-awesome,
  ...
} @ args:
with python3Packages;
  buildPythonPackage rec {
    inherit (sources.bepasty) pname version src;

    propagatedBuildInputs = [
      flask
      pygments
      setuptools
      xstatic
      xstatic-asciinema-player
      xstatic-bootbox
      xstatic-bootstrap
      xstatic-font-awesome
      xstatic-jquery
      xstatic-jquery-file-upload
      xstatic-jquery-ui
      xstatic-pygments
    ];

    buildInputs = [setuptools-scm];

    doCheck = false;

    meta = with lib; {
      description = "universal pastebin server";
      homepage = "https://bepasty-server.readthedocs.org/";
      license = with licenses; [bsd2];
    };
  }
