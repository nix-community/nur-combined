{ lib, fetchFromGitHub, buildGoPackage }:

buildGoPackage rec {
  pname = "queued-build-hook";
  version = "2020-02-12";
  goPackagePath = "github.com/nix-community/queued-build-hook";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "queued-build-hook";
    rev = "8c21c1bcd62bf488d7e1267f09ebf147a948994a";
    sha256 = "sha256-kk37GkFWovRwXTClPnWwChRb3ajf73HiRp8LpAfsMFg=";
  };

  meta = {
    description = "Queue and retry Nix post-build-hook";
    homepage = "https://github.com/nix-community/queued-build-hook";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.adisbladis ];
  };
}
