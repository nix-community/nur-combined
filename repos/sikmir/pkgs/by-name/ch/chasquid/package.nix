{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "chasquid";
  version = "1.18.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "albertito";
    repo = "chasquid";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FNr1DjH5AaLZdPsLy/jowpXkX3YhLkH2ygUANMD9ON0=";
  };

  vendorHash = "sha256-zRd4CCLv9gVLykLazGH2P+XPKO8xh5QKshFrVP4YIZY=";

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
    "-X main.version=${finalAttrs.version}"
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
})
