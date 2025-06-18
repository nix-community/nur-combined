{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "goto";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "grafviktor";
    repo = "goto";
    tag = "v${version}";
    hash = "sha256-xQIsA/UC9daR1k6c3TMsWWIt3iYVeHd96OxYlFo27oI=";
  };

  vendorHash = "sha256-IiwanGg/Q28GWb7+BeHAZbhTP8ZHXiUG1XTwEu5v88w=";

  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=${version}"
  ];

  meta = {
    description = "A simple SSH manager";
    homepage = "https://github.com/grafviktor/goto";
    license = lib.licenses.mit;
    mainProgram = "goto";
    maintainers = [ lib.maintainers.sikmir ];
  };
}
