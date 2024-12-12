{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule rec {
  pname = "chasquid";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "albertito";
    repo = "chasquid";
    tag = "v${version}";
    hash = "sha256-BgW3qZlP6KPiD/gNJ68dSiwt+Xg3FhC0Q8aoK+Ud1sM=";
  };

  vendorHash = "sha256-dOQJJ2U9Y7zyCNNxUMX85BNMlqn9/KQbZB2CWiYaylc=";

  subPackages = [
    "."
    "cmd/chasquid-util"
    "cmd/smtp-check"
    "cmd/mda-lmtp"
  ];

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  postInstall = ''
    installManPage docs/man/*.{1,5}
  '';

  meta = {
    description = "SMTP (email) server with a focus on simplicity, security, and ease of operation";
    homepage = "https://blitiri.com.ar/p/chasquid/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "chasquid";
  };
}
