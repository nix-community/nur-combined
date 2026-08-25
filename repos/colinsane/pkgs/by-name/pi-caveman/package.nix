{
  fetchFromGitHub,
  gitUpdater,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pi-caveman";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "vanillagreencom";
    repo = "vstack";
    tag = "pi-caveman-v${finalAttrs.version}";
    hash = "sha256-kXYyL8dlROietumjzNZco33ZuLFGq4PzjxEvxPJhOLM=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R pi-extensions/pi-caveman/. $out/
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "pi-caveman-v";
  };

  meta = {
    description = "Native Pi caveman communication mode with session persistence, slash command control, status badge, and settings-manager integration.";
    homepage = "https://github.com/vanillagreencom/vstack/tree/main/pi-extensions/pi-caveman";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
