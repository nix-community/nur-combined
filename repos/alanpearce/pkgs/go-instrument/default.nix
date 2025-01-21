{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "go-instrument";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "nikolaydubina";
    repo = "go-instrument";
    rev = "v${version}";
    hash = "sha256-0WoID8hYtAu4EJbEgvHtJtE5keq33aGDMjFU9B+MLh8=";
  };

  vendorHash = "sha256-dofJA3Xxf68r4nKv6ocAYgnvOZD8eeezkaXLOqlRI6k=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Automatically add Trace Spans to Go methods and functions";
    homepage = "https://github.com/nikolaydubina/go-instrument";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alanpearce ];
    mainProgram = "go-instrument";
  };
}
