{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "kdigger";
  version = "2022-01-19-unstable";

  src = fetchFromGitHub {
    owner = "quarkslab";
    repo = pname;
    rev = "7d856366ab753309caab61ce7c2050d5cb04abe8";
    sha256 = "sha256-5LhBgAzoLzMkEoktrWNDKv5J4fVeFnO1CJX16AYxI6o=";
  };
  vendorSha256 = "sha256-lM9oYvf6yKwLJpsTDCBVW8KYr3mY4MOLg9ODXaeLMWY=";

  nativeBuildInputs = [ installShellFiles ];

  # go version and arch not set automatically
  ldflags = [
    "-s"
    "-w"
    "-X github.com/quarkslab/kdigger/commands.VERSION=7d856366ab753309caab61ce7c2050d5cb04abe8"
  ];

  postInstall = ''
    installShellCompletion --cmd kdigger \
      --bash <($out/bin/kdigger completion bash) \
      --fish <($out/bin/kdigger completion fish) \
      --zsh <($out/bin/kdigger completion zsh)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/kdigger --help

    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/quarkslab/kdigger";
    changelog = "https://github.com/quarkslab/kdigger/releases/tag/v${version}";
    description = "A context discovery tool for Kubernetes penetration testing";
    longDescription = ''
      kdigger, short for "Kubernetes digger", is a context discovery tool for
      Kubernetes penetration testing. This tool is a compilation of various
      plugins called buckets to facilitate pentesting Kubernetes from inside a
      pod.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
