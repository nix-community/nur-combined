{ callPackage }:

rec {
  about-time = callPackage ../development/python-modules/about-time { };
  alive-progress = callPackage ../development/python-modules/alive-progress { inherit about-time; };
  aws-error-utils = callPackage ../development/python-modules/aws-error-utils { };
  curlify = callPackage ../development/python-modules/curlify { };
  mypy-boto3-ebs = callPackage ../development/python-modules/mypy-boto3-ebs { };
}
