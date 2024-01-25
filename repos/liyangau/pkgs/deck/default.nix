{ pkgs, buildGoModule, lib, installShellFiles, fetchFromGitHub }:
let
  short_hash = "856c55d";
in
buildGoModule rec {
  pname = "deck";
  version = "1.32.0";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = "deck";
    rev = "v${version}";
    hash = "sha256-h0dZXIrQm8RlfNnIHU4P0iFelWmkXVqkBmyyrA3/EgY=";
  };

  nativeBuildInputs = [ installShellFiles ];

  CGO_ENABLED = 0;

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${short_hash}"
  ];

  vendorHash = "${
    if pkgs.stdenvNoCC.isDarwin
    then "sha256-BtNVEydWna+qiWtPKzzIAgYGnCVCyzkNG1+UcOhjBXE="
    else "sha256-LpW3G8BLl+IegFR1z5qOTqW+PhpmZcAeSWESMSNuTIw="
  }";

  passthru.updateScript = ./update.sh;

  postInstall = ''
    installShellCompletion --cmd deck \
      --bash <($out/bin/deck completion bash) \
      --fish <($out/bin/deck completion fish) \
      --zsh <($out/bin/deck completion zsh)
  '';

  meta = with lib; {
    description = "A configuration management and drift detection tool for Kong";
    homepage = "https://github.com/Kong/deck";
    license = licenses.asl20;
    maintainers = with maintainers; [ liyangau ];
  };
}
