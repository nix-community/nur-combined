{ lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "git-along-unstable-${version}";
  version = "2019-12-30";

  goPackagePath = "github.com/nyarly/git-along";

  src = fetchFromGitHub {
    owner = "nyarly";
    repo = "git-along";
    rev = "a1c51e8b554312173c4922bdfe3c10a9b500f7ce";
    sha256 = "q/XZrZ4jW9ZPVf8zcW6gsdMS42d56Ze/aF6HKAwM7XM=";
  };

  meta = with lib; {
    description = "Manage project configuration and environment in side branches";
    homepage = https://github.com/nyarly/git-along;
    maintaines = [ maintainers.robertodr ];
  };
}
