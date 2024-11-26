{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule rec {
  pname = "kumactl";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "kumahq";
    repo = "kuma";
    rev = version;
    hash = "sha256-aU1YYYnE7hkVL7f5zd/FXgAW95PpLCIGF4+Ulh3Dq4Q=";
  };

  vendorHash = "sha256-R4wqWKXWGaYD+AaeO1D9Sv5tAsHarCV+UT/wO1Nrc4s=";

  nativeBuildInputs = [ installShellFiles ];
  CGO_ENABLED = 0;
  flags = [
    "-trimpath"
  ];
  proxyVendor = true;
  subPackages = "app/kumactl";

  preBuild = ''
    export HOME=$TMPDIR
  '';

  postInstall = ''
    installShellCompletion --cmd kumactl \
      --bash <($out/bin/kumactl completion bash) \
      --fish <($out/bin/kumactl completion fish) \
      --zsh <($out/bin/kumactl completion zsh)
  '';

  ldflags =
    let
      prefix = "github.com/kumahq/kuma/pkg/version";
    in
    [
      "-s"
      "-w"
      "-X ${prefix}.version=${version}"
      "-X ${prefix}.gitTag=${version}"
      "-X ${prefix}.gitCommit=${version}"
      "-X ${prefix}.buildDate=${version}"
      "-X ${prefix}.Envoy=1.30.6"
    ];

  meta = with lib; {
    description = "Service mesh controller";
    homepage = "https://kuma.io/";
    changelog = "https://github.com/kumahq/kuma/blob/${version}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ zbioe ];
  };
}
