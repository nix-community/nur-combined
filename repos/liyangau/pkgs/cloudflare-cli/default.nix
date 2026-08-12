{
  buildNpmPackage,
  lib,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "cloudflare-cli";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "ylbeethoven";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-GJLlUkR72wSa9LM3Rx+rEGQl8otbDFFxja9kRRpv5lE=";
  };

  dontNpmBuild = true;

  npmDepsHash = "sha256-ka1yz+QXTs03bWfnHvKHfCQrPstxO0kZZHCGm8EqWUU=";

  meta = {
    description = "CLI for interacting with Cloudflare";
    license = lib.licenses.asl20;
    homepage = "https://github.com/ylbeethoven/cloudflare-cli";
  };
}
