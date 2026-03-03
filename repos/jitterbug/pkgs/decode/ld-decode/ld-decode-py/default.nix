{
  python3Packages,
  ffmpeg,
  ...
}:
python3Packages.buildPythonPackage {
  pname = "ld-decode-py";

  pyproject = true;

  build-system = [
    python3Packages.setuptools
  ];

  buildInputs = [
    ffmpeg
  ];

  propagatedBuildInputs = [
    python3Packages.av
    python3Packages.matplotlib
    python3Packages.numpy
    python3Packages.numba
    python3Packages.scipy
  ];

  pythonImportsCheck = [
    "lddecode"
  ];
}
