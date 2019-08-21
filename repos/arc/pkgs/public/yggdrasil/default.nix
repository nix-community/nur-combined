let
  version = "0.3.8";
  buildPackage = pname: { buildGoPackage, fetchFromGitHub, lib }: lib.drvExec "bin/${pname}" (buildGoPackage {
    inherit pname version;
    goPackagePath = "github.com/yggdrasil-network/yggdrasil-go";
    subPackages = ["cmd/${pname}"];
    src = fetchFromGitHub {
      owner = "yggdrasil-network";
      repo = "yggdrasil-go";
      rev = "v${version}";
      sha256 = "1jkbfx6mnzqqcqmdmll7bb44d94xa5iam704dpm2jmyk5pcvdhld";
    };

    goDeps = ./deps.nix;
  });
in {
  yggdrasil = buildPackage "yggdrasil";
  yggdrasilctl = buildPackage "yggdrasilctl";
}
