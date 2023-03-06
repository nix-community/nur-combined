{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, lark
}:

buildPythonPackage rec {
  pname = "check-shapes";
  version = "1.0.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "GPflow";
    repo = "check_shapes";
    rev = "v${version}";
    hash = "sha256-lTfJJ3gjpMmhLPoTSS9zlQj6q4w+v65F94Qwsaym6Xw=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    lark
  ];

  pythonImportsCheck = [ "check_shapes" ];

  meta = with lib; {
    description = "Library for annotating and checking tensor shapes";
    homepage = "https://github.com/GPflow/check_shapes";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
