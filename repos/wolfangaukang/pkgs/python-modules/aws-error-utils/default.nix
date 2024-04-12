{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, botocore
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "aws-error-utils";
  version = "2.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "benkehoe";
    repo = "aws-error-utils";
    rev = "v${version}";
    hash = "sha256-ZOSQDay6KqDqUxSiiMqw2fBkbquRzRO+YGD+aVhrCdA=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [ botocore ];

  checkInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "aws_error_utils" ];

  meta = with lib; {
    description = "Making botocore.exceptions.ClientError easier to deal with";
    homepage = "https://github.com/benkehoe/aws-error-utils";
    changelog = "https://github.com/benkehoe/aws-error-utils/releases/tag/${src.rev}";
    licenses = licenses.asl20;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
