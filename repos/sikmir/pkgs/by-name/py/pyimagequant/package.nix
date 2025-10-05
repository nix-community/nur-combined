{
  lib,
  stdenv,
  fetchFromGitHub,
  python311Packages,
}:

python311Packages.buildPythonPackage {
  pname = "pyimagequant";
  version = "0-unstable-2022-06-10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "pyimagequant";
    rev = "55a76cb90c75b598d40bd92cf61e6ec9aa846d1e";
    hash = "sha256-80SsAcN0iEaEEQpNTsi81n71DEQksSYiaSe/LQpqMbc=";
    fetchSubmodules = true;
  };

  postPatch = ''
    # error: could not create 'build': File exists
    rm BUILD
  '';

  build-system = with python311Packages; [ setuptools ];

  dependencies = with python311Packages; [ cython ];

  pythonImportsCheck = [ "imagequant" ];

  meta = {
    description = "Python bindings for libimagequant (pngquant core)";
    homepage = "https://github.com/wladich/pyimagequant";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
