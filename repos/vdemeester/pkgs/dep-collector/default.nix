{ stdenv, lib, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "dep-collector-unstable-${version}";
  version = "2018-11-29";
  rev = "2377fbc40f81501f2bc09a4e1e359a7ec7c3528e";

  goPackagePath = "github.com/knative/test-infra";
  subPackages = [ "tools/dep-collector" ];

  src = fetchgit {
    inherit rev;
    url = "https://github.com/knative/test-infra";
    sha256 = "053iazdfhqdb69knnpd2w5ikbyffp3ygvvdvvg253fwgk9s97jyj";
  };

  meta = {
    description = "Gathers the set of licenses for Go imports pulled in via dep.";
    homepage = https://github.com/mattmoor/dep-collector;
    license = lib.licenses.asl20;
  };
}
