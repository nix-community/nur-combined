{
  buildPythonPackage,
  lib,
  fetchFromGitHub,
  setuptools,
  wheel,
  poetry-core,
}:
buildPythonPackage {
  pname = "xontrib-zoxide";
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "dyuri";
    repo = "xontrib-zoxide";
    rev = "36d3d0bc5945f2cd7aefdff598c6f7eeccfb1770";
    hash = "sha256-lYx5dfmVebSYls9rbvAeD8GdzYkwv/qy75xp1m+/mdA=";
  };

  pyproject = true;

  doCheck = false;

  nativeBuildInputs = [
    setuptools
    wheel
    poetry-core
  ];

  postPatch = ''
    sed -ie "/xonsh.*=/d" pyproject.toml
  '';

  meta = with lib; {
    homepage = "https://github.com/dyuri/xontrib-zoxide";
    license = licenses.mit;
    # maintainers = [maintainers.drmikecrowe];
    description = "Zoxide integration in the [xonsh shell](https://xon.sh).";
  };
}
