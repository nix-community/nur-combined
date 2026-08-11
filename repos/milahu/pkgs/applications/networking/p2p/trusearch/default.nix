{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "trusearch";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "Snawoot";
    repo = "trusearch";
    rev = "v${version}";
    hash = "sha256-QmIy+Y0vLwkBZ5RAdsQrvV4Tj2ukcoPqhoNXvrs31N8=";
  };

  vendorHash = "sha256-YIZkdVLXS0oMkICBR5Q3AtsQT4lGMHDzzbaRo9CCQ+o=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Perform advanced search on unofficial rutracker.org (ex torrents.ru) XML database";
    homepage = "https://github.com/Snawoot/trusearch";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "trusearch";
  };
}
