{
  lib,
  python3Packages,
  fetchPypi,
  nur-pkgs,
}:
python3Packages.buildPythonApplication rec {
  pname = "gersemi";
  version = "0.25.1";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-oRn1/wxRM7JecqXDn3ciU1dByzEfZq4XvxqvHRGQdRo=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies =
    (with python3Packages; [
      lark
      pyyaml
      platformdirs
    ])
    ++ [nur-pkgs.ignore-python];

  meta = {
    description = "A formatter to make your CMake code the real treasure";
    homepage = "https://github.com/BlankSpruce/gersemi";
    license = lib.licenses.mpl20;
    mainProgram = "gersemi";
  };
}
