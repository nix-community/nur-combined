{ buildGoModule, fetchFromGitHub, lib, ... }:

buildGoModule rec{
  pname = "kim";
  version = "v0.1.0-beta.7";
  vendorSha256 = "sha256-uN6/XUbNNC/Tug1yfp7i7P3eMw/Shr5FWjLP2TfoWKE=";

  # src = builtins.fetchGit {
  #   url = "https://github.com/rancher/kim";
  #   ref = "refs/tags/${version}";
  # };

  src = fetchFromGitHub {
    owner = "rancher";
    repo = "kim";
    rev = "refs/tags/${version}";
    # rev = "e597b9564b47213734787b3e0c540a635b250bbf";
    sha256 = "sha256-/gmyM4vYgoGVHGlAi35ZkmBlhXcDRFgIFzwrX4uNQ5g=";
  };

  # preBuild = ''
  #   go mod vendor
  # '';
  #
  ldflags = [
    "-s" "-w"
    "-X github.com/rancher/kim/pkg/version.GitCommit=${src.rev}"
    "-X github.com/rancher/kim/pkg/version.Version=${version}"
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    [[ $($out/bin/kim --version) == "kim version ${version}"* ]]
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "In ur kubernetes, buildin ur imagez";
    longDescription = "kim is a Kubernetes-aware CLI that will install a small builder backend consisting of a BuildKit daemon bound to the Kubelet's underlying containerd socket (for building images) along with a small server-side agent that the CLI leverages for image management (think push, pull, etc) rather than talking to the backing containerd/CRI directly. kim enables building images locally, natively on your k3s cluster.";
    homepage = "https://github.com/rancher/kim";
    licenses = licenses.asl20;
    maintainers = with maintainers; [ congee ];  # not in <nixpkgs> yet
    mainProgram = "kim";
  };
}
