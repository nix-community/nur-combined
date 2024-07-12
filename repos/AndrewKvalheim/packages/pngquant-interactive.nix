{ fetchFromGitea
, gitUpdater
, lib
, rustPlatform

  # Dependencies
, cmake
, curl
, git
, libXcursor
, libXfixes
, libXinerama
, mesa
, pango
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "pngquant-interactive";
  version = "0.2.0";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "pngquant-interactive";
    rev = "v${version}";
    hash = "sha256-lEXBQ6toomT8Q8QDGz5l+ywcCGcuO3gKBymMDMlk+ak=";
  };

  cargoHash = "sha256-pyQevvMX7895pqlERs6N+kT1OxkTWwKW3fhNYzYve+8=";

  nativeBuildInputs = [ cmake curl git pkg-config ];
  buildInputs = [ libXcursor libXfixes libXinerama mesa pango ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Graphical interface for pngquant with a live preview";
    homepage = "https://codeberg.org/AndrewKvalheim/pngquant-interactive";
    license = lib.licenses.gpl3;
    mainProgram = pname;
  };
}
