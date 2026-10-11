{ lib
, fetchFromGitHub
, rustPlatform
}:
let
  pname = "budget-tracker-tui";
  version = "1.7.0";
  owner = "Feromond";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub rec {
    inherit owner;
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-WflCwLK4GI0UOzpJGnZBpNd1EDoxn/+wTgNz4HXfbaY=";
  };

  cargoHash = "sha256-zWL9LH83iz/bgodo19Pfitiuqj5Q5M93AgMOFwRErxk=";

  # There is no tests
  doCheck = false;

  meta = {
    description = "A TUI budget tracker app. Tracks income and expenses and help visualize and gather basic insights from your transactions.";
    homepage = "https://github.com/Feromond/budget-tracker-tui";
    changelog = "https://github.com/Feromond/budget-tracker-tui/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "budget-tracker";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
  };
}
