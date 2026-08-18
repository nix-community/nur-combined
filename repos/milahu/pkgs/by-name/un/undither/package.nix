{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "undither";
  version = "0.2-unstable-2023-11-15";

  src = fetchFromGitHub {
    owner = "kornelski";
    repo = "undither";
    # https://github.com/kornelski/undither/pull/8
    rev = "bf5cf3bcf2bd7050a10e3cc4a7bb6103df5548be";
    hash = "sha256-r3Hw2NIlVHER8vZHtZSLQPzeBYj4pEQHl72/zlU7UjE=";
  };

  cargoHash = "sha256-q/WtEoqgNW9LuJkA47fCB4FicIOhQAxsqEvj69aJdjc=";

  buildFeatures = [
    "binary"
  ];

  meta = {
    description = "Smart filter to remove Floyd-Steinberg dithering from paletted images";
    homepage = "https://github.com/kornelski/undither";
    # Cargo.toml: license = "GPL-3.0+"
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "undither";
  };
})
