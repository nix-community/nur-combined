{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wayclick";
  version = "0-unstable-2026-07-20";

  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "wayclick";
    rev = "7eb8d9d0e615abe2c4ace1c300497737b8d94d6f";
    hash = "sha256-9IzF5YWw2plY/kGM0LBkde3tVfNulwF+QbyHKM///CA=";
  };

  cargoHash = "sha256-QYp5B+amLHIY4Yr/kCKngbv4voeBdiY+8czbcWvmdtQ=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
  ];

  postInstall = ''

    mkdir -p $out/share/wayclick
    cp -r $src/assets/default $out/share/wayclick/config
  '';

  passthru.updateArgs = [ "--version=branch" ];

  meta = {
    description = "Low-latency key click sound engine using evdev + pygame";
    homepage = "https://github.com/lonerOrz/wayclick";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "wayclick";
  };
})
