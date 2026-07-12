{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.xstatic-asciinema-player) pname version;
  pyproject = true;

  inherit (sources.xstatic-asciinema-player) src;

  build-system = [ setuptools ];

  postPatch = ''
    substituteInPlace xstatic/__init__.py xstatic/pkg/__init__.py \
      --replace-fail "__import__('pkg_resources').declare_namespace(__name__)" ""
    sed -i '/namespace_packages/d' setup.py
  '';

  pythonImportsCheck = [ "xstatic.pkg.asciinema_player" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Asciinema-player packaged for setuptools (easy_install) / pip";
    homepage = "https://github.com/asciinema/asciinema-player";
    license = with lib.licenses; [ asl20 ];
  };
}
