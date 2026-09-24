{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  ffmpeg,
  libpulseaudio,
  freetype,
  harfbuzz,
  fribidi,
}:
rustPlatform.buildRustPackage rec {
  pname = "enzo";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "MiguelRegueiro";
    repo = "enzo";
    rev = "v${version}";
    hash = "sha256-xNIUmJysDNft+NRe9yHpVK+guyUr6OEqoJpPZ/gzJUE=";
  };

  cargoHash = "sha256-zbq000kD664dVgL7OuwHJj+EOiTVw/yokzaNPdmgSfc=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    ffmpeg
    libpulseaudio
    freetype
    harfbuzz
    fribidi
  ];

  meta = with lib; {
    description = "Terminal video player";
    homepage = "https://github.com/MiguelRegueiro/enzo";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
    mainProgram = "enzo";
  };
}
