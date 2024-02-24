{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "gpx-converter";
  version = "0-unstable-2023-04-07";

  src = fetchFromGitHub {
    owner = "nidhaloff";
    repo = "gpx-converter";
    rev = "0dac5d7eaf83d7bb99631b52d4d210dc010e4b60";
    hash = "sha256-bT94phfkJiOQ8rZn783qOmIph6ck27z18rQQby9uEeg=";
  };

  propagatedBuildInputs = with python3Packages; [ gpxpy numpy pandas ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook pytest-runner ];

  disabledTests = [ "test_gpx_to_dictionary" ];

  meta = with lib; {
    description = "Python package for manipulating gpx files and easily convert gpx to other different formats";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
