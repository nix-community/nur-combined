{
  lib,
  sources,
  buildPythonPackage,
}:
buildPythonPackage rec {
  inherit (sources.xstatic-font-awesome) pname version src;

  pythonImportsCheck = [ "xstatic.pkg.font_awesome" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Font Awesome packaged for setuptools (easy_install) / pip";
    homepage = "https://github.com/FortAwesome/Font-Awesome";
    license = with lib.licenses; [ ofl ];
  };
}
