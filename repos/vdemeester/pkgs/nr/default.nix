{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "nr-${version}";
  version = "0.3.0";
  rev = "v${version}";

  goPackagePath = "github.com/vdemeester/nr";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "nr";
    sha256 = "1k7qzsv9jqmgpk9dv2cv4islrkwrswgkk6lkaryndrfa6i7w112d";
  };

  meta = {
    description = "a nix run alias generator";
    homepage = "https://github.com/vdemeester/nr";
    license = lib.licenses.asl20;
  };
}
