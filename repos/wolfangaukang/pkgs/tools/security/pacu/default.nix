{ lib
, buildPythonApplication
, fetchFromGitHub
, poetry-core
, awscli
, boto3
, dsnap
, requests
, sqlalchemy
, sqlalchemy-utils
, typing-extensions
, pythonRelaxDepsHook
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "pacu";
  version = "1.0.3";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "RhinoSecurityLabs";
    repo = "pacu";
    rev = "v${version}";
    sha256 = "sha256-tt6Jkfxs+UVmu8eIC2M7lmnePgYVt9jkF2l1moQLl4A=";
  };

  propagatedBuildInputs = [
    poetry-core
    awscli
    boto3
    dsnap
    requests
    sqlalchemy
    sqlalchemy-utils
    typing-extensions
    pythonRelaxDepsHook
  ];

  pythonRelaxDeps = [
    "dsnap"
    "SQLAlchemy"
    "SQLAlchemy-Utils"
    "typing-extensions"
  ];

  checkInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  meta = with lib; {
    description = "The AWS exploitation framework, designed for testing the security of Amazon Web Services environments";
    homepage = "https://rhinosecuritylabs.com/aws/pacu-open-source-aws-exploitation-framework/";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
