{ buildGoModule, fetchFromGitHub, lib, ... }:
buildGoModule rec {
  pname = "svu";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "caarlos0";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-MztFramrNqxYmdTRf857HOC7H66dLvezG6LL9njxWUs=";
  };

  vendorHash = "sha256-+e1oL08KvBSNaRepGR2SBBrEDJaGxl5V9rOBysGEfQs=";

  # test assumes source directory to be a git repository
  postPatch = ''
    rm internal/git/git_test.go
  '';

  ldflags =
    [ "-s" "-w" "-X=main.version=${version}" "-X=main.builtBy=nixpkgs" ];

  meta = with lib; {
    description = "Semantic Version Util";
    homepage = "https://github.com/caarlos0/svu";
    license = licenses.mit;
  };
}
