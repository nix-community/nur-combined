{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "krew-${version}";
  version = "0.3.4";
  rev = "v${version}";

  goPackagePath = "github.com/kubernetes-sigs/krew";
  subPackages = [ "cmd/krew" ];
  src = fetchFromGitHub {
    inherit rev;
    owner = "kubernetes-sigs";
    repo = "krew";
    sha256 = "0n10kpr2v9jzkz4lxrf1vf9x5zql73r5q1f1llwvjw6mb3xyn6ij";
  };
  modSha256 = "01sgzi6cfdx2p1mbfbcxh8vivrj79qmzsflah9n6j5favn8sqsl3";

  meta = {
    description = "The package manager for 'kubectl plugins. ";
    homepage = "https://github.com/kubernetes-sigs/krew";
    license = lib.licenses.asl20;
  };
}
