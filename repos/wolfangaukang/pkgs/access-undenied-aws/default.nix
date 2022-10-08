{ lib
, fetchFromGitHub
, python3Packages
, aws-error-utils
#, boto3
#, cachetools
#, click
#, click-log
#, colorlog
#, setuptools
}:

python3Packages.buildPythonApplication rec {
  pname = "access-undenied-aws";
  version = "0.1.5";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "ermetic";
    repo = "access-undenied-aws";
    rev = "v${version}";
    sha256 = "sha256-xShsgc9oXsm5dzqeg0DTdGPFJvd8v8DrO87jUmcTxEc=";
  };

  patches = [ 
    ./requirements.patch
  ]; 

  propagatedBuildInputs = with python3Packages; [
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
    licenses = licenses.asl20;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
