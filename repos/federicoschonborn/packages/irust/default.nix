{ lib
, rustPlatform
, fetchFromGitHub
, nix-update-script
}:

rustPlatform.buildRustPackage rec {
  pname = "irust";
  version = "1.71.18";

  src = fetchFromGitHub {
    owner = "sigmaSd";
    repo = "IRust";
    rev = "irust@${version}";
    hash = "sha256-T8WZHgr1npVddA2/CIFOEYVZBGw7w4bBIrOc1qe60ac=";
  };

  cargoHash = "sha256-Aiise8rrk30IOD7DZyH3TD+LO6FWtzq9NyWjp6aGHno=";

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    mainProgram = "irust";
    description = "Cross Platform Rust Repl";
    homepage = "https://github.com/sigmaSd/IRust";
    changelog = "https://github.com/sigmaSd/IRust/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
