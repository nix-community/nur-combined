{ callPackage }:

{
  awsipranges = callPackage ../python-modules/awsipranges { };
  aws-error-utils = callPackage ../python-modules/aws-error-utils { };
}
