{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "nr-${version}";
  version = "0.2.3";
  rev = "v${version}";

  goPackagePath = "github.com/vdemeester/nr";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "nr";
    sha256 = "1h8j6zkvjb149x9q10yxhl4zqaqpq7l8pg0xkcgc9cc5m1x93mh7";
  };

  meta = {
    description = "a nix run alias generator";
    homepage = "https://github.com/vdemeester/nr";
    license = lib.licenses.asl20;
  };
}
