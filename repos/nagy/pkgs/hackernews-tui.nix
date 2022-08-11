{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "hackernews-tui";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-v/HM0oCgsGX4CqFKJyMhTqATvN5/TgolhJjjWnygRec=";
  };

  cargoSha256 = "sha256-CM14L9UykIT3KFMqtHhy3cYA4TR6pTEutkgi0gGDpZw=";

  meta = with lib; {
    description = "Terminal UI to browse Hacker News";
    homepage = "https://github.com/aome510/hackernews-TUI";
    license = with licenses; [ mit ];
    mainProgram = "hackernews_tui";
  };
}
