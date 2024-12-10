{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  flask,
  pygments,
  setuptools-scm,
  setuptools,
  xstatic-asciinema-player,
  xstatic-bootbox,
  xstatic-bootstrap,
  xstatic-font-awesome,
  xstatic-jquery-file-upload,
  xstatic-jquery-ui,
  xstatic-jquery,
  xstatic-pygments,
  xstatic,
}:
buildPythonPackage rec {
  inherit (sources.bepasty) pname version src;
  pyproject = true;

  propagatedBuildInputs = [
    flask
    pygments
    setuptools
    setuptools-scm
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

  pythonImportsCheck = [ "bepasty" ];

  meta = {
    mainProgram = "bepasty-server";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Universal pastebin server";
    homepage = "https://bepasty-server.readthedocs.org/";
    license = with lib.licenses; [ bsd2 ];
  };
}
