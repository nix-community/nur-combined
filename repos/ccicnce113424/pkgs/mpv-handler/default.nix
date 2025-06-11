{
  sources,
  lib,
  rustPlatform,
  copyDesktopItems,
}:
rustPlatform.buildRustPackage (final: {
  inherit (sources) pname version src;

  cargoLock = sources.cargoLock."Cargo.lock";

  nativeBuildInputs = [ copyDesktopItems ];
  desktopItems = [
    "${final.src}/share/linux/mpv-handler.desktop"
    "${final.src}/share/linux/mpv-handler-debug.desktop"
  ];

  meta = {
    description = "Protocol handler for mpv";
    homepage = "https://github.com/akiirui/mpv-handler";
    license = lib.licenses.mit;
  };
})
