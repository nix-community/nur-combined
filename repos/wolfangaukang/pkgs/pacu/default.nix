{ lib
, buildPythonApplication
, fetchFromGitHub
, boto3
, botocore
, chalice
, dsnap
, jq
, policyuniverse
, pycognito
, pyyaml
, qrcode
, requests
, sqlalchemy
, sqlalchemy-utils
, typing-extensions
, urllib3
, awscli
, poetry-core
, freezegun
, moto
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "pacu";
  version = "1.4.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "RhinoSecurityLabs";
    repo = "pacu";
    rev = "v${version}";
    hash = "sha256-Z+2ltaR+/tDfAKo0qpzpPk1/jMH7LShBcpeppipXEX0=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    boto3
    botocore
    chalice
    dsnap
    jq
    policyuniverse
    pycognito
    pyyaml
    qrcode
    requests
    sqlalchemy
    sqlalchemy-utils
    typing-extensions
    urllib3
  ] ++ [ awscli ];

  checkInputs = [
    freezegun
    moto
    pytestCheckHook
  ];

  preCheck = ''
    # Solves PermissionError: [Errno 13] Permission denied: '/homeless-shelter'
    export HOME=$(mktemp -d)
  '';

  disabledTests = [
    # sqlalchemy.exc.ArgumentError
    "test_migrations"
  ];

  meta = with lib; {
    description = "The AWS exploitation framework, designed for testing the security of Amazon Web Services environments";
    homepage = "https://rhinosecuritylabs.com/aws/pacu-open-source-aws-exploitation-framework/";
    changelog = "https://github.com/RhinoSecurityLabs/pacu/releases/tag/${src.rev}";
    license = licenses.bsd3;
    platforms = platforms.linux;
    mainProgram = "pacu";
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
