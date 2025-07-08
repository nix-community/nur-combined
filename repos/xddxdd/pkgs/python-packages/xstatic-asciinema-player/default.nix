{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.xstatic-asciinema-player) pname version src;
  pyproject = true;

  build-system = [ setuptools ];

  pythonImportsCheck = [ "xstatic.pkg.asciinema_player" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Asciinema-player packaged for setuptools (easy_install) / pip";
    homepage = "https://github.com/asciinema/asciinema-player";
    license = with lib.licenses; [ asl20 ];
  };
}
