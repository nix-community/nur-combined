{
  lib,
  rustPlatform,
  pkg-config,
  libinput,
  udev,
  xdotool,

  sources,
  source ? sources.ferstar-gestures,

  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (source) pname version src;

  cargoLock.lockFile = source.cargoLock."Cargo.lock".lockFile;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libinput
    udev
    xdotool
  ];

  doInstallCheck = true;
  nativeCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Fast touchpad gesture tool";
    homepage = "https://github.com/ferstar/gestures";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "gestures";
    platforms = lib.platforms.linux;
  };
})
