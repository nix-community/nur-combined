{ lib, fetchFromGitHub, rustPlatform, testers, hackernews-tui }:

rustPlatform.buildRustPackage rec {
  pname = "hackernews-tui";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-z5xe+cvkAzI7Dx3xxOhVZT4UYSsi1j/qdVghb+01dfg=";
  };

  cargoSha256 = "sha256-Fk/3aWDlyU1J28JBLBknS9GCDClar05Lt3JgWw+uhuw=";

  passthru.tests.version = testers.testVersion {
    package = hackernews-tui;
  };

  meta = with lib; {
    description = "Terminal UI to browse Hacker News";
    homepage = "https://github.com/aome510/hackernews-TUI";
    license = with licenses; [ mit ];
    mainProgram = "hackernews_tui";
  };
}
