{ lib
#, buildPythonApplication
, fetchFromGitHub
, python3
, alive-progress
#, arnparse
#, azure-identity
#, azure-mgmt-authorization
#, azure-mgmt-security
#, azure-mgmt-storage
#, azure-mgmt-subscription
#, azure-storage-blob
#, botocore
#, boto3
#, detect-secrets
#, msgraph-core
#, pydantic
#, shodan
#, tabulate
#, moto
#, sure
#, pytestCheckHook
}:

let
  changeVersion = packageToOverride: version: sha256: packageToOverride (oldAttrs: rec {
    inherit version;
    src = oldAttrs.src.override {
      inherit version sha256;
    };
  });

  py = python3.override {
    packageOverrides = self: super: {
      botocore = changeVersion super.botocore.overridePythonAttrs "1.29.18" "sha256-JuhvzpUEn2zBi1YRkBVJlDxMIlIvqKO2smVAT2c5d7I=";
      boto3 = changeVersion super.boto3.overridePythonAttrs "1.26.17" "sha256-u0CpeI3SI0hRzdERDuwOP2s69rmCgJJPpEwlGZztVzc=";

      tabulate = super.tabulate.overridePythonAttrs (oldAttrs: rec {
        version = "0.9.0";
        format = "pyproject";
        src = oldAttrs.src.override {
          inherit version;
          sha256 = "sha256-AJWxK/WWbeUpwP6x+ghnFnGzNo7sd9fverEUviwGizw=";
        };

        propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or []) ++ [
          super.setuptools-scm
        ];

        SETUPTOOLS_SCM_PRETEND_VERSION = version;
      });
    };
  };
in
with py.pkgs;

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
