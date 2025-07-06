{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "gpx-converter";
  version = "0-unstable-2023-04-07";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nidhaloff";
    repo = "gpx-converter";
    rev = "0dac5d7eaf83d7bb99631b52d4d210dc010e4b60";
    hash = "sha256-bT94phfkJiOQ8rZn783qOmIph6ck27z18rQQby9uEeg=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'pytest-runner'," ""
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    gpxpy
    numpy
    pandas
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  disabledTests = [ "test_gpx_to_dictionary" ];

  meta = {
    description = "Python package for manipulating gpx files and easily convert gpx to other different formats";
    homepage = "https://github.com/nidhaloff/gpx-converter";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
