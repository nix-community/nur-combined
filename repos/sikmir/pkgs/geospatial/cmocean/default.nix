{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "cmocean";
  version = "4.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "matplotlib";
    repo = "cmocean";
    tag = "v${version}";
    hash = "sha256-Vi+tK2cAwqkoe2CEFCYEqMp28IgeH1MSJ+u3t6D8Zu8=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    matplotlib
    numpy
  ];

  doCheck = !stdenv.isDarwin;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Colormap setup for standardizing commonly-plotting oceanographic variables";
    homepage = "https://github.com/matplotlib/cmocean";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
