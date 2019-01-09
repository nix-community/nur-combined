{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "ram-${version}";
  version = "0.2.1";
  rev = "v${version}";

  goPackagePath = "github.com/vdemeester/ram";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "ram";
    sha256 = "0bphmr97s0j3w56gd31k93f5f5d6z6nz3vrn8m1grai6b7ivf21c";
  };

  meta = {
    description = "A golang opiniated continuous testing tool 🐏";
    homepage = "https://github.com/vdemeester/ram";
    license = lib.licenses.asl20;
  };
}
