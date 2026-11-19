{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wayclick";
  version = "1.1.0-unstable-2026-11-19";

  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "wayclick";
    rev = "32366e1177dcab43137aaf5804a2fff5a610539c";
    hash = "sha256-jsUnZHqgO5yQGKAyVwZoBhDCnxBIo6rZS+31wlBAIWw=";
  };

  cargoHash = "sha256-tZ/u1NNETzKu7m5ap1NqAQJTtZZoaDbpZR09W/yalss=";

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
