{
  fetchurl,
  lib,
  buildPythonPackage,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "xstatic-font-awesome";
  version = "6.2.1.2";
  pyproject = true;

  src = fetchurl {
    url = "mirror://pypi/X/XStatic-Font-Awesome/xstatic_font_awesome-${finalAttrs.version}.tar.gz";
    hash = "sha256-nzyy8Dj619NSciN10/Ja80banuCT7Z3CyMRr2RGrGXE=";
  };
  build-system = [ setuptools ];

  pythonImportsCheck = [ "xstatic.pkg.font_awesome" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Font Awesome packaged for setuptools (easy_install) / pip";
    homepage = "https://github.com/FortAwesome/Font-Awesome";
    license = with lib.licenses; [ ofl ];
  };
})
