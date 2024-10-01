{
  buildGoModule,
  lib,
  installShellFiles,
  fetchFromGitHub,
}:
let
  short_hash = "cd165de";
  package_hash = "sha256-n6WASCtDwBX4FASSWI17JpU7rDXIeSidPWhj/MB2tUs=";
  latest_version = "1.40.3";
in
buildGoModule rec {
  pname = "deck";
  version = "${latest_version}";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = "deck";
    rev = "refs/tags/v${version}";
    hash = "${package_hash}";
  };

  nativeBuildInputs = [ installShellFiles ];

  CGO_ENABLED = 0;

  flags = [
    "-trimpath"
  ];

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${short_hash}"
  ];

  vendorHash = "sha256-csoSvu7uce1diB4EsQCRRt08mX+rJoxfZqAtaoo0x4M=";

  proxyVendor = true;

  postInstall = ''
    installShellCompletion --cmd deck \
      --bash <($out/bin/deck completion bash) \
      --fish <($out/bin/deck completion fish) \
      --zsh <($out/bin/deck completion zsh)
  '';

  meta = {
    description = "A configuration management and drift detection tool for Kong";
    homepage = "https://github.com/Kong/deck";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ liyangau ];
  };
}
