{
  fetchurl,
  lib,
  buildPythonPackage,
  setuptools,
}:
buildPythonPackage rec {
  pname = "xstatic-font-awesome";
  version = "6.2.1.2";
  pyproject = true;

  src = fetchurl {
    url = "mirror://pypi/X/XStatic-Font-Awesome/XStatic-Font-Awesome-${version}";
    hash = "sha256-4B+0gMqqfHlj3LMyikcA5jG+9gcNsOi2hYFtIg5oX2w=";
  };
  build-system = [ setuptools ];

  postPatch = ''
    substituteInPlace xstatic/__init__.py xstatic/pkg/__init__.py \
      --replace-fail "__import__('pkg_resources').declare_namespace(__name__)" ""
    sed -i '/namespace_packages/d' setup.py
  '';

  pythonImportsCheck = [ "xstatic.pkg.font_awesome" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Font Awesome packaged for setuptools (easy_install) / pip";
    homepage = "https://github.com/FortAwesome/Font-Awesome";
    license = with lib.licenses; [ ofl ];
  };
}
