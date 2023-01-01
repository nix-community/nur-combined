{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, boto3
, typer
, mock
, moto
, mypy-boto3-ebs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "dsnap";
  version = "1.0.0";
  format = "pyproject";

  # Picking from GitHub to retrieve tests
  src = fetchFromGitHub {
    owner = "RhinoSecurityLabs";
    repo = "dsnap";
    rev = "v${version}";
    sha256 = "sha256-yKch+tKjFhvZfzloazMH378dkERF8gnZEX1Som+d670=";
  };

  propagatedBuildInputs = [
    poetry-core
    boto3
    typer
  ];

  checkInputs = [
    mock
    moto
    mypy-boto3-ebs
    pytestCheckHook
  ];

  meta = with lib; {
    description = "Utility for downloading and mounting EBS snapshots using the EBS Direct API's";
    homepage = "https://github.com/RhinoSecurityLabs/dsnap";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
