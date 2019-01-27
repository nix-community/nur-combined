{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "nr-${version}";
  version = "0.2.2";
  rev = "v${version}";

  goPackagePath = "github.com/vdemeester/nr";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "nr";
    sha256 = "0jk8pswky7b7z4zgx3hq62y488kx21b0hq2zw4crhphqan7lp3za";
  };

  meta = {
    description = "a nix run alias generator";
    homepage = "https://github.com/vdemeester/nr";
    license = lib.licenses.asl20;
  };
}
