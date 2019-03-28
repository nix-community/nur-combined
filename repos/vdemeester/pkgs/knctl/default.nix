{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "knctl-${version}";
  version = "0.3.0";
  rev = "v${version}";

  goPackagePath = "github.com/cppforlife/knctl";
  subPackages = [ "cmd/knctl" ];

  src = fetchFromGitHub {
    inherit rev;
    owner = "cppforlife";
    repo = "knctl";
    sha256 = "1sy6iwcfn26862jwllbzjr47lwz493hjqcfay3sigbl71k8zprin";
  };

  meta = {
    description = "Knative CLI";
    homepage = https://github.com/cppforlife/knctl;
    license = lib.licenses.asl20;
  };
}
