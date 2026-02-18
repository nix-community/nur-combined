{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "chasquid";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "albertito";
    repo = "chasquid";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KOfZKUK6KuW0yaDm5ZbjzGH3xYb84mNmIzEbSDjPtSk=";
  };

  vendorHash = "sha256-u+4Ncr0P32avy8+ZLAzZHCqNm9zNVIC8m618ENh7IXg=";

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
