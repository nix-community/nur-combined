{
  fetchurl,
  lib,
  buildPythonPackage,
  nix-update-script,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "xstatic-asciinema-player";
  version = "2.6.1.1";
  pyproject = true;

  src = fetchurl {
    url = "mirror://pypi/X/XStatic-asciinema-player/XStatic-asciinema-player-${finalAttrs.version}.tar.gz";
    hash = "sha256-yA6WC067St82Dm6StaCKdWrRBhmNemswetIO8iodfcw=";
  };
  build-system = [ setuptools ];

  postPatch = ''
    substituteInPlace xstatic/__init__.py xstatic/pkg/__init__.py \
      --replace-fail "__import__('pkg_resources').declare_namespace(__name__)" ""
    sed -i '/namespace_packages/d' setup.py
  '';

  pythonImportsCheck = [ "xstatic.pkg.asciinema_player" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Asciinema-player packaged for setuptools (easy_install) / pip";
    homepage = "https://github.com/asciinema/asciinema-player";
    license = with lib.licenses; [ asl20 ];
  };
})
