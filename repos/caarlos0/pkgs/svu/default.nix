{ buildGoModule, fetchFromGitHub, lib, ... }:
buildGoModule rec {
  pname = "svu";
  version = "1.10.2";

  src = fetchFromGitHub {
    owner = "caarlos0";
    repo = pname;
    rev = "v${version}";
    sha256 = "37AT+ygN7u3KfFqr26M9c7aTt15z8m4PBrSd+G5mJcE=";
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
