{ lib, fetchFromGitHub, rustPlatform, pkg-config, sqlite }:

rustPlatform.buildRustPackage rec {
  pname = "raspi-oled";
  version = "unstable-infdev-2";

  src = fetchFromGitHub {
    owner = "FliegendeWurst";
    repo = "raspi-oled";
    rev = "1a5272b7ba987df5b84eef1f92764d335762748e";
    sha256 = "sha256-VPEKGNckXIDSzA2rwtUGYNyTSEzcseDOwVnG9xEb0nw=";
  };

  cargoSha256 = "sha256-JUR96YDgZz7GUMWZr4bG+iHvMVSxkaUMvVf7hLpI5KI=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ sqlite ];
  RUSTC_BOOTSTRAP = "1";

  meta = with lib; {
    description = "OLED display of clock/calendar/temperature";
    homepage = "https://github.com/FliegendeWurst/raspi-oled";
    license = licenses.mit;
    maintainers = with maintainers; [ fliegendewurst ];
  };
}

