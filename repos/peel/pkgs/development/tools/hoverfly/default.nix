{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "hoverfly-${version}";
  version = "v0.17.2";
  rev = "${version}";

  goPackagePath = "github.com/SpectoLabs/hoverfly";

  src = fetchFromGitHub {
    inherit rev;
    owner = "SpectoLabs";
    repo = "hoverfly";
    sha256 = "0flxs4msafadpy8yh63zczxc3532g9cvp9ravapkvipfcvl9mww6";
  };
  meta = with stdenv.lib; {
    description = "Lightweight service virtualization/API simulation tool for developers and testers";
    homepage = "http://hoverfly.io";
    license = licenses.asl20;
  };
}
