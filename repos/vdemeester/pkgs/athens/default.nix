{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "athens-${version}";
  version = "0.5.0";
  rev = "v${version}";

  goPackagePath = "github.com/gomods/athens";

  src = fetchFromGitHub {
    inherit rev;
    owner = "gomods";
    repo = "athens";
    sha256 = "1fsvnzw3l1qfvga6r7vfzq1sda9ggdl2ps81v0cqcr9d8ggpgzhc";
  };

  modSha256 = "1fanb3mhvnldkryz74yarcwl4ma6353mfkivs5hr678g6785srqj";

  meta = {
    description = "a Go module datastore and proxy";
    homepage = "https://github.com/godmods/athens";
    license = lib.licenses.mit;
  };
}
