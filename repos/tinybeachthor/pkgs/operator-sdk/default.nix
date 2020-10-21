{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "operator-sdk-${version}";
  version = "0.16.0";
  rev = "v${version}";

  goPackagePath = "github.com/operator-framework/operator-sdk";

  subPackages = [ "cmd/operator-sdk" ];

  src = fetchFromGitHub {
    inherit rev;
    owner = "operator-framework";
    repo = "operator-sdk";
    sha256 = "1qdvnfxz81ij1y7qdk5xjq0nd3dqgbdjq0gmramxmkkz892cdaf3";
  };

  vendorSha256 = "sha256-aRwremxroH6lvkVEHh0Nl39NtR0BScB0lq0YWnpBl6A=";

  meta = {
    description = "SDK for building Kubernetes applications. Provides high level APIs, useful abstractions, and project scaffolding";
    homepage = https://github.com/operator-framework/operator-sdk;
    license = lib.licenses.asl20;
  };
}
