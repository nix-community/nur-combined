{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

let
  envoyPinnedNixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/a219f9fb3f229f1d033e36d53e6e8fb0a93a06eb.tar.gz";
    sha256 = "0dpbbsp26xrimv3iidjvkfa35qrlf8q8yjiyvaas9hb0wq83nwl2";
  }) { };
  pinnedEnvoy = envoyPinnedNixpkgs.envoy;
  corednsPinnedNixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/a2bbafe80837f46d6812616cbb06dee2420afc34.tar.gz";
    sha256 = "13ah1dbdb14bi30v6paj1j96d5xz1d7p87qfmklck3w0qh8w673w";
  }) { };
  pinnedCoreDNS = corednsPinnedNixpkgs.coredns;
in
buildGoModule rec {
  pname = "kuma-dp";
  version = "2.8.4";

  src = fetchFromGitHub {
    owner = "kumahq";
    repo = "kuma";
    rev = version;
    hash = "sha256-1W8DgooyHjy0H0Pzs3QBMnUMvcKpYZ1vZuoJQq9vuic=";
  };

  vendorHash = "sha256-do6zAN+4WuOEJQJwKQF3x28jtwWFMR2u8ESlbmqWIR4=";

  nativeBuildInputs = [ installShellFiles ];
  CGO_ENABLED = 0;
  flags = [
    "-trimpath"
  ];
  proxyVendor = true;
  subPackages = "app/kuma-dp";
  
  postInstall = ''
    installShellCompletion --cmd deck \
      --bash <($out/bin/kuma-dp completion bash) \
      --fish <($out/bin/kuma-dp completion fish) \
      --zsh <($out/bin/kuma-dp completion zsh)

    ln -sLf ${pinnedEnvoy}/bin/envoy $out/bin
    ln -sLf ${pinnedCoreDNS}/bin/coredns $out/bin
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
