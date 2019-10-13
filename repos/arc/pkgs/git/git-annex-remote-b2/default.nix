{ stdenv, buildGoPackage, fetchFromGitHub }: buildGoPackage rec {
  pname = "git-annex-remote-b2";
  version = "2019-10-11-arc";

  goPackagePath = "github.com/encryptio/git-annex-remote-b2";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = pname;
    rev = "c1141bcc2f8c72ced81bf8bcd60e3f692184c814";
    sha256 = "1dag6h661zgm09d9yk00vyswn5p4i7adl2clbsjf36v0910q9mvi";
  };

  goDeps = ./deps.nix;
}
