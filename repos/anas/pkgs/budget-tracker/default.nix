{ lib
, fetchFromGitHub
, rustPlatform
}:
let
  pname = "budget-tracker-tui";
  version = "1.8.1";
  owner = "Feromond";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub rec {
    inherit owner;
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-j8JK1zBIFJyPp+sT4lB7IX9mB4WLsRiCI2fec4ocYU4=";
  };

  patches = [
    ./0001-clean-remove-the-auto-update-functionallty.patch
  ];

  cargoHash = "sha256-IYFzqcvpDu4KrGrJl5T3Sir6MG7b1SFIgdY/8HiAPAg=";

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
