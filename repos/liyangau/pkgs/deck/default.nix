{ buildGoModule, lib, installShellFiles, fetchFromGitHub }:
let
  short_hash = "48e236c";
in buildGoModule rec {
  pname = "deck";
  version = "1.28.0";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = "deck";
    rev = "v${version}";
    sha256 = "00r45vs6425c1daqh3i1ysdq6n91lm9bi43qkgiccmrcl9srjl42";
  };

  nativeBuildInputs = [ installShellFiles ];

  CGO_ENABLED = 0;

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${short_hash}"
  ];

  vendorHash = "sha256-uxnFbuEhWwi3YO7662c17zhYL4KB5NbBUqQ+p5tqHUY=";

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