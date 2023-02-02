{ lib
, buildPythonApplication
, fetchFromGitHub
, python3
, alive-progress
, arnparse
, azure-identity
, azure-mgmt-authorization
, azure-mgmt-security
, azure-mgmt-storage
, azure-mgmt-subscription
, azure-storage-blob
, botocore
, boto3
, detect-secrets
, msgraph-core
, pydantic
, shodan
, tabulate
, freezegun
, moto
, sure
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "prowler";
  version = "3.0.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "prowler-cloud";
    repo = "prowler";
    rev = version;
    sha256 = "sha256-q7LgFmk+f/rjbaV3E8nykyC/U+2PXGYxD5gH+Va013g=";
  };

  # pythonRelaxDepsHook won't work on this project
  patches = [
    ./relax-alive-progress.patch
  ];

  propagatedBuildInputs = [
    alive-progress
    arnparse
    azure-identity
    azure-mgmt-authorization
    azure-mgmt-security
    azure-mgmt-storage
    azure-mgmt-subscription
    azure-storage-blob
    botocore
    boto3
    detect-secrets
    msgraph-core
    pydantic
    shodan
    tabulate
  ];

  checkInputs = [
    freezegun
    moto
    sure
    pytestCheckHook
  ];

  meta = with lib; {
    description = "Open Source Security tool to perform Cloud Security best practices assessments, audits, incident response, continuous monitoring, hardening and forensics readiness";
    homepage = "https://github.com/prowler-cloud/prowler";
    licenses = licenses.asl20;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
