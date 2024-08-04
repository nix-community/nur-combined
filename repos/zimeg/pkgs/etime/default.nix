{ lib
, buildGoModule
, installShellFiles
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "etime";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "zimeg";
    repo = "emporia-time";
    rev = "refs/tags/v${version}";
    hash = "sha256-8MuasxThi6JynfGIVAlU51C/7WfjobViKgcBU0gavvY=";
  };

  vendorHash = "sha256-QzqIIwLngBxmb2BGTEVsYvO8PvFGOY9sytA6ERztpFs=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    mv $out/bin/emporia-time $out/bin/etime
    installManPage etime.1
  '';

  meta = with lib; {
    description = "an energy aware `time` command";
    homepage = "https://github.com/zimeg/emporia-time";
    changelog = "https://github.com/zimeg/emporia-time/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "etime";
  };
}
