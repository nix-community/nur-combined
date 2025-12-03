{ python3, fetchFromGitHub }:
let
  python = python3;
in
python.pkgs.buildPythonPackage {
  pname = "borgstore";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "borgbackup";
    repo = "borgstore";
    tag = "0.3.0";
    hash = "sha256-R92m5yXj6FrHPjkQ3JzJG8ZwMLSaGC40dfkvvDkophc=";
  };

  patches = [ ./require-boto3.patch ];

  build-system = [ python.pkgs.setuptools-scm ];

  dependencies = with python.pkgs; [
    requests
    paramiko
    boto3
  ];
}
