{
  pkgs,
  buildGoModule,
  lib,
  installShellFiles,
  fetchFromGitHub,
}:
let
  short_hash = "74b1859";
  package_hash = "sha256-wb7/g1g7gxKhZyK7GW+6aGwuD+Dkcdg2Zpc0JCxVPjM=";
  latest_version = "1.40.1";
in
buildGoModule rec {
  pname = "deck";
  version = "${latest_version}";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = "deck";
    rev = "v${version}";
    hash = "${package_hash}";
  };

  nativeBuildInputs = [ installShellFiles ];

  CGO_ENABLED = 0;

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${short_hash}"
  ];

  vendorHash = "sha256-8o3jXkhfRIGGPtw8ow+NyAYAuCJNrBlSyfdSI0pjvDQ=";

  proxyVendor = true;

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
