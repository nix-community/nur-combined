{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "krew-${version}";
  version = "0.3.2";
  rev = "v${version}";

  goPackagePath = "github.com/kubernetes-sigs/krew";
  subPackages = [ "cmd/krew" ];
  src = fetchFromGitHub {
    inherit rev;
    owner = "kubernetes-sigs";
    repo = "krew";
    sha256 = "0zn3m1s3h8nghshxy1llzc51ranbyaj3v25zbjwjcq16gpak16i7";
  };
  modSha256 = "04w2gqi0q58fj5sz173fcjkgnb1npki4484c35y562j21gvzmc33";

  meta = {
    description = "The package manager for 'kubectl plugins. ";
    homepage = "https://github.com/kubernetes-sigs/krew";
    license = lib.licenses.asl20;
  };
}
