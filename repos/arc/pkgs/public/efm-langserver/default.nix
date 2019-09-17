{ buildGoPackage, fetchFromGitHub }: buildGoPackage rec {
  pname = "efm-langserver";
  version = "0.0.2";
  src = fetchFromGitHub {
    owner = "mattn";
    repo = pname;
    rev = "v${version}";
    sha256 = "06208492p4qqkybqf0jgb5smn0x09sf2k8870v4szrds2rd5arkw";
  };

  goPackagePath = "github.com/mattn/efm-langserver";

  goDeps = ./deps.nix;
}
