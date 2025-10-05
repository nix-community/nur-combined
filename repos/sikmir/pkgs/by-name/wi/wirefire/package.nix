{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule {
  pname = "wirefire";
  version = "0-unstable-2024-11-08";

  src = fetchFromGitHub {
    owner = "riyaz-ali";
    repo = "wirefire";
    rev = "0eb8f9d860f402040a15483f9beb6df3a6215156";
    hash = "sha256-Z4C+99HLu/ecShkZ6YwUJpp7m4Sj5tftRG1cPF5K9Cg=";
  };

  vendorHash = "sha256-RRahISh6nPSDc+iCZ/EEb6Oa1vQAlhBwaxPc5eTRzHw=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Lightweight, open-source implementation of Tailscale control server";
    homepage = "https://github.com/riyaz-ali/wirefire";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "wirefire";
  };
}
