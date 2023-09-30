{ lib, fetchFromGitHub, rustPlatform, testers, hackernews-tui }:

rustPlatform.buildRustPackage rec {
  pname = "hackernews-tui";
  version = "0.13.2";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-P5t6zA0wCpLMlRU+FeEum08h+PmqyQlYN/DoZ2TDntc=";
  };

  cargoSha256 = "sha256-Ti7wMqfKq4nakFV58MXHc2DQ1BXHe+uuH4VYL3xC0zo=";

  passthru.tests.version = testers.testVersion { package = hackernews-tui; };

  meta = with lib; {
    description = "Terminal UI to browse Hacker News";
    homepage = "https://github.com/aome510/hackernews-TUI";
    license = with licenses; [ mit ];
    mainProgram = "hackernews_tui";
  };
}
