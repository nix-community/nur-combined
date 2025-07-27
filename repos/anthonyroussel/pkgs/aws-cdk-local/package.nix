{
  pkgs,
  stdenv,
  lib,
  makeWrapper,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage {
  pname = "aws-cdk-local";
  version = "0-unstable-2025-04-22";

  src = fetchFromGitHub {
    owner = "localstack";
    repo = "aws-cdk-local";
    rev = "9bb17186e0201a93d84edd0e8478f7da69ae5414";
    hash = "sha256-1cgcBXe2N8sSNWe2L0QO8/MiBpAWKGz5DBxtl5s3+Lw=";
  };

  npmDepsHash = "sha256-pEjsZKGiXYhavaxkBNXXzhF4GxFqJo1IZ/jIo1wSgIs=";

  dontNpmBuild = true;

  makeWrapperArgs = [
    "--prefix NODE_PATH : ${pkgs.nodePackages.aws-cdk}/lib/node_modules"
  ];

  meta = {
    description = "CDK Toolkit for use with LocalStack";
    license = lib.licenses.asl20;
    homepage = "https://github.com/localstack/aws-cdk-local";
    maintainers = [ lib.maintainers.anthonyroussel ];
    platforms = lib.platforms.unix;
  };
}
