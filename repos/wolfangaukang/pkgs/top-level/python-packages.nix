{ lib, newScope, python3 }:

let
  inherit (lib) makeScope;
  inherit (python3.pkgs) callPackage;

in makeScope newScope (self: with self; {
    aws-error-utils = callPackage ../development/python-modules/aws-error-utils { };
    mypy-boto3-ebs = callPackage ../development/python-modules/mypy-boto3-ebs { };
  })

