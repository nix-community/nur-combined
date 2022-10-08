{ lib
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonPackage rec {
  pname = "aws-error-utils";
  version = "2.5";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "benkehoe";
    repo = "aws-error-utils";
    rev = "v${version}";
    sha256 = "sha256-rw2ErQ1v3FeKdwTTeBEGDUhSkV+G0oU0u6F9aXfEXH0=";
  };

  patches = [
    ./poetry-core.patch
  ];

  nativeBuildInputs = with python3Packages; [
    poetry-core
  ];

  propagatedBuildInputs = with python3Packages; [
    botocore
  ];

  checkInputs = with python3Packages; [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "aws_error_utils"
  ];

  meta = with lib; {
    description = "Making botocore.exceptions.ClientError easier to deal with";
    homepage = "https://github.com/benkehoe/aws-error-utils";
    licenses = licenses.asl20;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
