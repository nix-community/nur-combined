{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "ram-${version}";
  version = "0.1.0";
  rev = "v${version}";

  goPackagePath = "github.com/vdemeester/ram";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "ram";
    sha256 = "1jd3547wfk6sfb6h0asvmil90g10a16qznx8552rzywbr8c6i547";
  };

  meta = {
  description = "A golang opiniated continuous testing tool 🐏";
    homepage = "https://github.com/vdemeester/ram";
    licence = lib.licenses.asl20;
  };
}
