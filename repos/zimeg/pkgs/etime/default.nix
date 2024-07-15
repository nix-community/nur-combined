{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "etime";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "zimeg";
    repo = "emporia-time";
    rev = "refs/tags/v${version}";
    hash = "sha256-MykqGYAHCkDqgYbJyo6iBy4U2745i5KRMcwecNhlHb8=";
  };

  vendorHash = "sha256-o8PEb6lXD/99+VSYX+NOLBR4hRa1/3EltDIVx9owjDk=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${version}"
  ];

  postInstall = ''
    mv $out/bin/emporia-time $out/bin/etime
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
