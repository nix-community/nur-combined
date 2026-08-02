{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wayclick";
  version = "0-unstable-2026-08-01";

  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "wayclick";
    rev = "36ec706fd10863d1af09ca0fde5f589d773e7d38";
    hash = "sha256-LlJ80MrMLeaaVtq+mfwoW+mfGWEf5KlT9pNfUYwes3c=";
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
