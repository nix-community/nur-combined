{
  fetchFromGitHub,
  gitUpdater,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pi-caveman";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "vanillagreencom";
    repo = "vstack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SLknqH4493K6TziPdtN+OZUvUJcP1TUIRETlS0eM2DA=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R pi-extensions/pi-caveman/. $out/
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Native Pi caveman communication mode with session persistence, slash command control, status badge, and settings-manager integration.";
    homepage = "https://github.com/vanillagreencom/vstack/tree/main/pi-extensions/pi-caveman";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
