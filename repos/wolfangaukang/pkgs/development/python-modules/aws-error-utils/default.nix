{ lib
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonPackage rec {
  pname = "aws-error-utils";
  version = "2.7";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "benkehoe";
    repo = "aws-error-utils";
    rev = "v${version}";
    sha256 = "sha256-ZOSQDay6KqDqUxSiiMqw2fBkbquRzRO+YGD+aVhrCdA=";
  };

  nativeBuildInputs = with python3Packages; [ poetry-core ];

  propagatedBuildInputs = with python3Packages; [ botocore ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "aws_error_utils" ];

  meta = with lib; {
    description = "Making botocore.exceptions.ClientError easier to deal with";
    homepage = "https://github.com/benkehoe/aws-error-utils";
    licenses = licenses.asl20;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
