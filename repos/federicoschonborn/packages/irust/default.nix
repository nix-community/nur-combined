{ lib
, rustPlatform
, fetchFromGitHub
, nix-update-script
}:

rustPlatform.buildRustPackage rec {
  pname = "irust";
  version = "1.71.19";

  src = fetchFromGitHub {
    owner = "sigmaSd";
    repo = "IRust";
    rev = "irust@${version}";
    hash = "sha256-R3EAovCI5xDCQ5R69nMeE6v0cGVcY00O3kV8qHf0akc=";
  };

  cargoHash = "sha256-2aVCNz/Lw7364B5dgGaloVPcQHm2E+b/BOxF6Qlc8Hs=";

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
