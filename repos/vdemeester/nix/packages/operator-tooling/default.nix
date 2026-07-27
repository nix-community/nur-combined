{ stdenv, lib, buildGoModule, git, fetchFromGitHub }:

buildGoModule rec {
  name = "operator-tool-${version}";
  version = "0.0.3";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;
    owner = "openshift-pipelines";
    repo = "operator-tooling";
    sha256 = "sha256-S2EKdv/Y3ha+wMMK90jr5RPq3+2IJyX63c/xEEvrxrE=";
  };
  vendorHash = null;

  meta = {
    description = "Tooling for managing operator remote payload";
    homepage = https://github.com/openshift-pipelines/operator-tooling;
    license = lib.licenses.asl20;
  };
}
