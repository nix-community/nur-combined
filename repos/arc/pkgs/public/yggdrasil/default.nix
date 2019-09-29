let
  version = "0.3.9";
  buildPackage = pname: { buildGoPackage, fetchFromGitHub, lib }: lib.drvExec "bin/${pname}" (buildGoPackage {
    inherit pname version;
    goPackagePath = "github.com/yggdrasil-network/yggdrasil-go";
    subPackages = ["cmd/${pname}"];
    src = fetchFromGitHub {
      owner = "yggdrasil-network";
      repo = "yggdrasil-go";
      rev = "v${version}";
      sha256 = "1qn3p8450y95b8f9zy2j8mndwb19ypnk77vgw0yd412ppaiynj3l";
    };

    goDeps = ./deps.nix;
  });
in {
  yggdrasil = buildPackage "yggdrasil";
  yggdrasilctl = buildPackage "yggdrasilctl";
}
