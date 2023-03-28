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
, poetry-core
, pydantic
, schema
, shodan
, tabulate
, freezegun
, moto
, sure
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "prowler";
  version = "3.3.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "prowler-cloud";
    repo = "prowler";
    rev = version;
    sha256 = "sha256-gWM/8/QqZrglvkqG6ca+gHj1cIFqU6xusuLs/F5PDqM=";
  };

  # pythonRelaxDepsHook won't work on this project
  patches = [
    ./relax-alive-progress.patch
  ];

  nativeBuildInputs = [ poetry-core ];

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
    schema
    shodan
    tabulate
  ];

  disabledTests = [
    "test_send_to_s3_bucket"
    "test_ec2_default_snapshots"
    "test_ec2_public_snapshot"
    "test_ec2_private_snapshot"
    "test_ec2_default_snapshots"
    "test_ec2_unencrypted_snapshot"
    "test_ec2_encrypted_snapshot"
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
