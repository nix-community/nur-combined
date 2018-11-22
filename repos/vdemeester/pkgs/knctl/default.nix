{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "knctl-${version}";
  version = "0.1.0";
  rev = "v${version}";

  goPackagePath = "github.com/cppforlife/knctl";
  subPackages = [ "cmd/knctl" ];

  src = fetchFromGitHub {
    inherit rev;
    owner = "cppforlife";
    repo = "knctl";
    sha256 = "1j83wck1bmr0icfzpncwcq72sl55vfd2cxlg6zbwnzgiwvxchkj3";
  };

  meta = {
    description = "Knative CLI";
    homepage = https://github.com/cppforlife/knctl;
    license = lib.licenses.asl20;
  };
}
