{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "myx";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "HaseebKhalid1507";
    repo = "Myx";
    rev = "v${version}";
    hash = "sha256-72Q0AkUT8ms0+zbtVEBjqnku7njUAzVk/Y/d2AyQVeQ=";
  };

  cargoHash = "sha256-aNDKxvz918mwLteGpgQR7cpXs3VK12OHrfm4Q/jT+1s=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    alsa-lib
    openssl
  ];

  meta = with lib; {
    description = "A lean, beautiful terminal Spotify player";
    homepage = "https://github.com/HaseebKhalid1507/Myx";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
    mainProgram = "myx";
  };
}
