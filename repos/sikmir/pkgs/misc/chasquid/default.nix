{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "chasquid";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "albertito";
    repo = "chasquid";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IWGO7sIesVg6n2mFeZEHHmT2qRAO7/PbrQiNhvEDhrI=";
  };

  vendorHash = "sha256-rI4ClDcRWKywohe9uM3dXDrn5YfZjtJ4pxzheKDqIUk=";

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
