{
  buildGoModule,
  lib,
  installShellFiles,
  fetchFromGitHub,
}:
let
  short_hash = "63dc5b4";
  package_hash = "sha256-3T/ZLdLvTk18jC597j/5G3Hng57PDUvirsHPxfTMrGA=";
  latest_version = "1.41.3";
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
  doCheck = false;

  flags = [
    "-trimpath"
  ];

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${short_hash}"
  ];

  vendorHash = "sha256-S6xclqBshnjkMibEIQUa6Rj3PQRHxB7w6CUJ3tN39xs=";

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
