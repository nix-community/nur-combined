{ pkgs, buildGoModule, lib, installShellFiles, fetchFromGitHub }:
let
  short_hash = "6146f3a";
in
buildGoModule rec {
  pname = "deck";
  version = "1.30.0";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = "deck";
    rev = "v${version}";
    hash = "sha256-9h0jqbgd2UWJtRs1yZVTCORc3/ixCEMjx8sZByzBXVs=";
  };

  nativeBuildInputs = [ installShellFiles ];

  CGO_ENABLED = 0;

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${short_hash}"
  ];

  vendorHash = "${
    if pkgs.stdenvNoCC.isDarwin
    then "sha256-SGnXiezxtjlD/r6NvXOaxeEPfd4BdRfSSJxAt00XDgE="
    else "sha256-5UmNlPAYi98/WEY+NN2kDmmmlTd/csVRb1/ionrgFsE="
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
