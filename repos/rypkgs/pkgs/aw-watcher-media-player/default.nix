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
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "2e3s";
    repo = "aw-watcher-media-player";
    tag = "v${finalAttrs.version}";
    hash = "sha256-25yTA0JsfwowjVn4QvDHXNHVA+u6CqcEo8s+aY6JfIo=";
  };

  cargoHash = "sha256-9nkXSdxO/g8N2QyEW+zfoltN9ac+hSdoCXT2GEhKENE=";

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
