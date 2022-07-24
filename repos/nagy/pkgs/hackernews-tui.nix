{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "hackernews-tui";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-CWO6Ni+yNAUTyDPCw72cLDkn+WmsIdnY2mbYLbnySwI=";
  };

  cargoSha256 = "sha256-E4w/JssfGBzM1c0M38zN15t+EM5VYM7PL6TRss+6nEo=";

  meta = with lib; {
    description = "Terminal UI to browse Hacker News";
    homepage = "https://github.com/aome510/hackernews-TUI";
    license = with licenses; [ mit ];
    mainProgram = "hackernews_tui";
  };
}
