let
  version = "0.3.10";
  buildPackage = pname: { buildGoPackage, fetchFromGitHub, lib }: lib.drvExec "bin/${pname}" (buildGoPackage {
    inherit pname version;
    goPackagePath = "github.com/yggdrasil-network/yggdrasil-go";
    subPackages = ["cmd/${pname}"];
    src = fetchFromGitHub {
      owner = "yggdrasil-network";
      repo = "yggdrasil-go";
      rev = "v${version}";
      sha256 = "1h1xqg144adbgsiz00hjzxslakwfp3c5y8myczqq8nv46m29v110";
    };

    goDeps = ./deps.nix;
  });
in {
  yggdrasil = buildPackage "yggdrasil";
  yggdrasilctl = buildPackage "yggdrasilctl";
}
