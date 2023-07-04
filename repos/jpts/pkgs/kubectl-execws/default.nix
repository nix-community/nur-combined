{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  pname = "kubectl-execws";
  version = "0.3.0";
  owner = "jpts";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "v${version}";
    sha256 = "i87V1NK62fVtbf2U6vFi8in7JNQCBRM8K9i8eCi8hkY=";
  };
  vendorSha256 = "sha256-FU+DvsG2zGUdCXWAsL0xyok+YQjOhSAkSN41jCSXygA=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/jpts/kubectl-execws/cmd.releaseVersion=v${version}"
  ];

  nativeBuildInputs = [installShellFiles];

  postInstall = ''
    installShellCompletion --cmd kubectl-execws \
      --bash <($out/bin/kubectl-execws completion bash) \
      --zsh <($out/bin/kubectl-execws completion zsh) \
      --fish <($out/bin/kubectl-execws completion fish)

    ln -Tsf kubectl-execws $out/bin/kubectl_complete-execws
  '';

  meta = with lib; {
    homepage = "https://github.com/${owner}/${repo}";
    changelog = "https://github.com/${owner}/${repo}/tag/v${version}";
    description = "A replacement for \"kubectl exec\" that works over WebSocket connections.";
    longDescription = ''
      The Kubernetes API server has support for exec over WebSockets, but it has yet to land in kubectl. Although some proposals exist to add the functionality, they seem quite far away from landing. This plugin is designed to be a stopgap until they do.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
  };
}
