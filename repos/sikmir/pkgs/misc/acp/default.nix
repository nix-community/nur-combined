{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "acp";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Contextualist";
    repo = "acp";
    rev = "v${version}";
    hash = "sha256-qoS3lHr98S5uqmwZ3rZwPDZEQRTDIrxChfOlppbJHI4=";
  };

  vendorHash = "sha256-OCoghYUNznwBz7JN2MkHzdngA+mhHcfFIpw8ZMxeeMc=";

  ldflags = [ "-X main.buildTag=${version}" ];

  meta = with lib; {
    description = "Make terminal personal file transfers as simple as `cp`";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    mainProgram = "acp";
  };
}
