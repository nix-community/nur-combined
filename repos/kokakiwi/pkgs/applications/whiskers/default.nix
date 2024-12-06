{ lib

, fetchFromGitHub

, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "whiskers";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "whiskers";
    rev = "v${version}";
    hash = "sha256-OLEXy9MCrPQu1KWICsYhe/ayVqxkYIFwyJoJhgiNDz4=";
  };

  cargoHash = "sha256-ol8qdC+Cf7vG/X/Q7q9UZmxMWL8i49AI8fQLQt5Vw0A=";

  meta = with lib; {
    description = "Soothing port creation tool for the high-spirited";
    homepage = "https://github.com/catppuccin/whiskers";
    changelog = "https://github.com/catppuccin/whiskers/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    mainProgram = "whiskers";
  };
}
