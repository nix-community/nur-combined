{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "kubernetes-bom";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "kubernetes";
    repo = "release";
    rev = "v${version}";
    sha256 = "sha256-2Ikv8vxzNIRsgpUNFKVbDscGdS6Sj9FqsP4qELLK5cY=";
  };
  vendorSha256 = "sha256-vsDXejR/2M1Vsu3uzT4KI9QVE5RL8ZDPJAKjpULcfqg=";

  nativeBuildInputs = [ installShellFiles ];

  subPackages = ["cmd/bom"];

  ldflags = [ "-s" "-w" ];

  postInstall = ''
    installShellCompletion --cmd bom \
      --bash <($out/bin/bom completion bash) \
      --fish <($out/bin/bom completion fish) \
      --zsh <($out/bin/bom completion zsh)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/bom --help
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/kubernetes/release/tree/master/cmd/bom";
    description = "A utility to generate SPDX compliant Bill of Materials manifests";
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
