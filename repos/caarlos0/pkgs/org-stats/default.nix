{ buildGoModule, fetchFromGitHub, lib, ... }:
buildGoModule rec {
  pname = "org-stats";
  version = "1.11.2";

  src = fetchFromGitHub {
    owner = "caarlos0";
    repo = "org-stats";
    rev = "v${version}";
    sha256 = "sha256-b0Cfs4EqQOft/HNAoJvRriCMzNiOgYagBLiPYgsDgJM=";
  };

  vendorHash = "sha256-LKpnEXVfxBR3cebv46QontDVeA64MJe0vNiKSnTjLtQ=";

  meta = with lib; {
    description =
      "Get the contributor stats summary from all repos of any given organization";
    homepage = "https://github.com/caarlos0/org-stats";
    license = licenses.mit;
  };
}
