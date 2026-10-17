{
  lib,
  buildGoModule,
  go_1_27,
  fetchFromGitHub,
}:

# go.mod が go 1.27 を要求する。nixpkgs の既定 go が追いつくまで固定する
(buildGoModule.override { go = go_1_27; }) rec {
  pname = "gitcrawl";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "openclaw";
    repo = "gitcrawl";
    rev = "v${version}";
    hash = "sha256-vhxp7XHKEOTf7aRqhq/AqPyl2iTUhO46/obe1F7ZcRY=";
  };

  vendorHash = "sha256-FinnSrguUOCJDcQPiROOsFPbvGHAjoai4UxHGSgfZac=";

  subPackages = [ "cmd/gitcrawl" ];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/openclaw/gitcrawl/internal/cli.version=${version}"
  ];

  doCheck = false;

  meta = {
    description = "Local-first GitHub issue and pull request crawler for maintainer triage";
    homepage = "https://github.com/openclaw/gitcrawl";
    license = lib.licenses.mit;
    mainProgram = "gitcrawl";
  };
}
