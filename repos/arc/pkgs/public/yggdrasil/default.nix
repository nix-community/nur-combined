let
  version = "0.3.7";
  buildPackage = pname: { buildGoPackage, fetchFromGitHub, lib }: lib.drvExec "bin/${pname}" (buildGoPackage {
    inherit pname version;
    goPackagePath = "github.com/yggdrasil-network/yggdrasil-go";
    subPackages = ["cmd/${pname}"];
    src = fetchFromGitHub {
      owner = "yggdrasil-network";
      repo = "yggdrasil-go";
      rev = "v${version}";
      sha256 = "0pinkcbcxlyd5532dk8rk2jpd6946lw7c68jri1y9w17is9f51xa";
    };

    goDeps = ./deps.nix;
  });
in {
  yggdrasil = buildPackage "yggdrasil";
  yggdrasilctl = buildPackage "yggdrasilctl";
}
