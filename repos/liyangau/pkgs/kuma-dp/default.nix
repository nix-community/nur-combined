{
  lib,
  callPackage,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  system ? builtins.currentSystem,
}:

let
  envoyPinnedNixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/a219f9fb3f229f1d033e36d53e6e8fb0a93a06eb.tar.gz";
    sha256 = "0dpbbsp26xrimv3iidjvkfa35qrlf8q8yjiyvaas9hb0wq83nwl2";
  }) { inherit system; };
  pinnedEnvoy = envoyPinnedNixpkgs.envoy;

  coreDNS = callPackage ../coredns { };
in
buildGoModule rec {
  pname = "kuma-dp";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "kumahq";
    repo = "kuma";
    rev = version;
    hash = "sha256-aU1YYYnE7hkVL7f5zd/FXgAW95PpLCIGF4+Ulh3Dq4Q=";
  };

  vendorHash = "sha256-R4wqWKXWGaYD+AaeO1D9Sv5tAsHarCV+UT/wO1Nrc4s=";

  preBuild = ''
    export HOME=$TMPDIR
  '';

  nativeBuildInputs = [ installShellFiles ];
  CGO_ENABLED = 0;
  flags = [
    "-trimpath"
  ];
  proxyVendor = true;
  subPackages = "app/kuma-dp";

  postInstall = ''
    installShellCompletion --cmd kuma-dp \
      --bash <($out/bin/kuma-dp completion bash) \
      --fish <($out/bin/kuma-dp completion fish) \
      --zsh <($out/bin/kuma-dp completion zsh)
    ln -sLf ${pinnedEnvoy}/bin/envoy $out/bin
    ln -sLf ${coreDNS}/bin/coredns $out/bin
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
