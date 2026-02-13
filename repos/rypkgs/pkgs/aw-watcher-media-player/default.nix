{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aw-watcher-media-player";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "2e3s";
    repo = "aw-watcher-media-player";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6lVW2hd1nrPEV3uRJbG4ySWDVuFUi/JSZ1HYJFz0KdQ=";
  };

  cargoHash = "sha256-1HAoWrJUSQFhG0KbKR8ZEOykMWWtHxUj2OtvXlPhe4k=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    openssl
  ];

  meta = {
    description = "ActivityWatch media player watcher via MPRIS";
    homepage = "https://github.com/2e3s/aw-watcher-media-player";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
    mainProgram = "aw-watcher-media-player";
  };
})
