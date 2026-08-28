{
  lib,
  buildPythonPackage,
  fetchPypi,
  docutils,
  pygments,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyroma";
  version = "2.6.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-JSdCPjokzNVpUfPOGw67zE+gUYyC/KiC5pbHhyarnC8=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "pygments < 2.6" "pygments"
  '';

  propagatedBuildInputs = [
    docutils
    pygments
    setuptools
  ];

  meta = with lib; {
    description = "Test your project's packaging friendliness";
    homepage = "https://github.com/regebro/pyroma";
    license = licenses.mit;
  };
})
