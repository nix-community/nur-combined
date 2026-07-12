{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.xstatic-font-awesome) pname version;
  pyproject = true;

  inherit (sources.xstatic-font-awesome) src;

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
