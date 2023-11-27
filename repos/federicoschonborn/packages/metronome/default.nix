{ lib
, stdenv
, fetchFromGitLab
, cargo
, desktop-file-utils
, gst_all_1
, libadwaita
, meson
, ninja
, pkg-config
, rustc
, rustPlatform
, wrapGAppsHook4
, nix-update-script
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "metronome";
  version = "1.3.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "Metronome";
    rev = finalAttrs.version;
    hash = "sha256-Sn2Ua/XxPnJjcQvWeOPkphl+BE7/BdOrUIpf+tLt20U=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-HYO/IY5yGW8JLBxD/SZz16GFnwvv77kFl/x+QXhV+V0=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    libadwaita
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "metronome";
    description = "Keep the tempo";
    homepage = "https://gitlab.gnome.org/World/Metronome";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
