{
  lib,
  sources,
  python3Packages,
  xstatic-asciinema-player,
  xstatic-font-awesome,
  ...
}:
python3Packages.buildPythonPackage rec {
  inherit (sources.bepasty) pname version src;

  propagatedBuildInputs =
    [
      xstatic-asciinema-player
      xstatic-font-awesome
    ]
    ++ (with python3Packages; [
      flask
      pygments
      setuptools
      setuptools-scm
      xstatic
      xstatic-bootbox
      xstatic-bootstrap
      xstatic-jquery
      xstatic-jquery-file-upload
      xstatic-jquery-ui
      xstatic-pygments
    ]);

  format = "pyproject";

  doCheck = false;

  meta = with lib; {
    mainProgram = "bepasty-server";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Universal pastebin server";
    homepage = "https://bepasty-server.readthedocs.org/";
    license = with licenses; [ bsd2 ];
  };
}
