{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  setuptools,
  pdm-pep517,
}:
buildPythonPackage rec {
  pname = "xontrib-broot";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "jnoortheen";
    repo = "xontrib-broot";
    rev = "6f658ff88aba27b921017297d8c2c3dfb2ffa332";
    sha256 = "sha256-9GqsTVCMvrWpTopHtEdicTyYRQzP1NVtQHZsfBT+fUg=";
  };

  doCheck = false;

  format = "pyproject";

  build-system = [
    setuptools
    pdm-pep517
    poetry-core
  ];

  postPatch = ''
    sed -ie "/xonsh.*=/d" pyproject.toml
  '';

  meta = with lib; {
    description = "[broot](https://github.com/Canop/broot) support function in the [xonsh shell](https://xon.sh).";
    homepage = "https://github.com/jnoortheen/xontrib-broot";
    license = licenses.mit;
    # maintainers = [maintainers.drmikecrowe];
  };
}
