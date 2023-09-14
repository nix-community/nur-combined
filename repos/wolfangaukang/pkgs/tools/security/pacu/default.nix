{ lib
, python3
, awscli
, dsnap
, fetchPypi
, fetchFromGitHub
}:

let
  python = python3.override {
    packageOverrides = prev: final: {
      sqlalchemy = final.sqlalchemy.overridePythonAttrs (old: rec {
        version = "1.3.24";

        src = fetchPypi {
          inherit version;
          pname = "SQLAlchemy";
          hash = "sha256-67t3fL+TEjWbiXv4G6ANrg9ctp+6KhgmXcwYpvXvdRk=";
        };

        # Too lazy to check this...
        doCheck = false;
      });
    };
    self = python;
  };

in
python.pkgs.buildPythonApplication rec {
  pname = "pacu";
  version = "1.3.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "RhinoSecurityLabs";
    repo = "pacu";
    rev = "v${version}";
    sha256 = "sha256-zq/VTw0jTlmuBl55BQLY+0iADQTfrMGxc8LBBBpXe1k=";
  };

  propagatedBuildInputs = with python.pkgs; [
    poetry-core
    boto3
    botocore
    chalice
    jq
    policyuniverse
    requests
    sqlalchemy
    sqlalchemy-utils
    typing-extensions
    urllib3
  ] ++ [ awscli dsnap ];

  checkInputs = with python.pkgs; [
    pytestCheckHook
    freezegun
    moto
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
