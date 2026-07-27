{
  sources,

  lib,
  python3Packages,

  swig,
}:
python3Packages.buildPythonPackage {
  inherit (sources.py-slvs) pname version src;
  patches = [ ./cmake_policy_version_minimum.patch ];
  pyproject = true;

  nativeBuildInputs = [
    swig
  ];

  propagatedBuildInputs = with python3Packages; [
    cmake
    ninja
    setuptools
    scikit-build
  ];

  dontUseCmakeConfigure = true;

  meta = with lib; {
    description = "Python binding of SOLVESPACE geometry constraint solver";
    homepage = "https://github.com/realthunder/slvs_py";
    license = licenses.gpl3Plus;
  };
}
