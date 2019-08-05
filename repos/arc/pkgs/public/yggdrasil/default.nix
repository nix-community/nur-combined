let
  version = "0.3.5";
  buildPackage = pname: { buildGoPackage, fetchFromGitHub, lib }: lib.drvExec "bin/${pname}" (buildGoPackage {
    inherit pname version;
    goPackagePath = "github.com/yggdrasil-network/yggdrasil-go";
    subPackages = ["cmd/${pname}"];
    src = fetchFromGitHub {
      owner = "yggdrasil-network";
      repo = "yggdrasil-go";
      rev = "v${version}";
      sha256 = "0cbj9hqrgn93jlybf3mfpffb68yyizxlvrsh1s5q21jv2lhhjcwj";
    };

    goDeps = ./deps.nix;
  });
in {
  yggdrasil = buildPackage "yggdrasil";
  yggdrasilctl = buildPackage "yggdrasilctl";
}
