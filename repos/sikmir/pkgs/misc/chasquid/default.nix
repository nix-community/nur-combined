{ lib, stdenv, fetchFromGitHub, buildGoModule, installShellFiles }:

buildGoModule rec {
  pname = "chasquid";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "albertito";
    repo = "chasquid";
    rev = "v${version}";
    hash = "sha256-/BSWsDQBfSaXP/7RcCMRnd+nwQwya7vcUl4oZuc+Unk=";
  };

  vendorHash = "sha256-rx6b48I4Do84K0ffwlTT3moz46FyqEPR6E6cac1xI9E=";

  subPackages = [ "." "cmd/chasquid-util" "cmd/smtp-check" "cmd/mda-lmtp" ];

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [ "-X main.version=${version}" ];

  postInstall = ''
    installManPage docs/man/*.{1,5}
  '';

  meta = with lib; {
    description = "SMTP (email) server with a focus on simplicity, security, and ease of operation";
    homepage = "https://blitiri.com.ar/p/chasquid/";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    mainProgram = "chasquid";
  };
}
