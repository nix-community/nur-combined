{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "ram-${version}";
  version = "0.2.3";
  rev = "v${version}";

  goPackagePath = "github.com/vdemeester/ram";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "ram";
    sha256 = "155as4rmqcxlq0vv32hb3xqnijyz7i93678vfg2s490zn801ba4h";
  };

  meta = {
    description = "A golang opiniated continuous testing tool 🐏";
    homepage = "https://github.com/vdemeester/ram";
    license = lib.licenses.asl20;
  };
}
