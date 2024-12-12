{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "acp";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Contextualist";
    repo = "acp";
    tag = "v${version}";
    hash = "sha256-qoS3lHr98S5uqmwZ3rZwPDZEQRTDIrxChfOlppbJHI4=";
  };

  vendorHash = "sha256-OCoghYUNznwBz7JN2MkHzdngA+mhHcfFIpw8ZMxeeMc=";

  ldflags = [
    "-s"
    "-w"
    "-X main.buildTag=${version}"
  ];

  meta = {
    description = "Make terminal personal file transfers as simple as `cp`";
    homepage = "https://github.com/Contextualist/acp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "acp";
  };
}
