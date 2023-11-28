{ pkgs, buildGoModule, lib, installShellFiles, fetchFromGitHub }:
let
  short_hash = "77682ca";
in
buildGoModule rec {
  pname = "deck";
  version = "1.29.2";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = "deck";
    rev = "v${version}";
    hash = "sha256-UQgNLlV4FoKd23zkReTftDnHBtjtKjoXuqJPGTNX+CI=";
  };

  nativeBuildInputs = [ installShellFiles ];

  CGO_ENABLED = 0;

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${short_hash}"
  ];

  vendorHash = "${
    if pkgs.stdenvNoCC.isDarwin
    then "sha256-K+7NZ3ALd9WJ+GMc5Ptlg2eG4tbpBD/9hiU8CSznU6c="
    else "sha256-kVc0ElVGyyei5PMfZN+GPHeQYfSmmPRAFrW21MTi8Mk="
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
