{ config
, lib
, pkgs
, fetchFromGitHub
, rustPlatform
, pkg-config
, lz4
, libxkbcommon
}:
rustPlatform.buildRustPackage rec {
  pname = "swww";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "Horus645";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-9qTKaLfVeZD8tli7gqGa6gr1a2ptQRj4sf1XSPORo1s=";
  };
  cargoHash = "sha256-OWe+r8Vh09yfMFBjVH66i+J6RtHo1nDva0m1dJPZ4rE=";

  buildInputs = [ lz4 libxkbcommon ];
  doCheck = false; # Integration tests do not work in sandbox enviroment

  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    description = "Efficient animated wallpaper daemon for wayland, controlled at runtime";
    homepage = "https://github.com/Horus645/swww";
    maintainers = with maintainers; [ ocfox ];
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
