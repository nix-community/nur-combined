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
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "2e3s";
    repo = "aw-watcher-media-player";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DjoalKlnhUWEmun57G17/gtqifo3arcbkEw/vMVNWD0=";
  };

  cargoHash = "sha256-057Yjxac7BDb+7nohj51biUPHT1LN9iICihzp5cziWA=";

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
