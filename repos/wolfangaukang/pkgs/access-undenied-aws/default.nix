{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  aws-error-utils,
  boto3,
  cachetools,
  click,
  click-log,
  colorlog,
  setuptools,
}:

buildPythonApplication rec {
  pname = "access-undenied-aws";
  version = "0.1.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ermetic";
    repo = "access-undenied-aws";
    rev = "v${version}";
    hash = "sha256-xShsgc9oXsm5dzqeg0DTdGPFJvd8v8DrO87jUmcTxEc=";
  };

  patches = [
    ./requirements.patch
  ];

  propagatedBuildInputs = [
    aws-error-utils
    boto3
    cachetools
    click
    click-log
    colorlog
    setuptools
  ];

  # No tests
  doCheck = false;

  meta = with lib; {
    description = "Parses AWS AccessDenied CloudTrail events, explains the reasons for them, and offers actionable remediation steps";
    homepage = "https://github.com/ermetic/access-undenied-aws";
    changelog = "https://github.com/ermetic/access-undenied-aws/releases/tag/${src.rev}";
    licenses = licenses.asl20;
    mainProgram = "access-undenied-aws";
  };
}
