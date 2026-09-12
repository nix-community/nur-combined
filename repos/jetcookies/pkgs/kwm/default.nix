{
  lib,
  stdenv,
  fetchFromGitHub,
  makeDesktopItem,
  nix-update-script,
  river,

  pkg-config,
  zig_0_16,

  fcft,
  libxkbcommon,
  pixman,
  wayland,
  wayland-scanner,
  wayland-protocols,
}:
let
  zig = zig_0_16;
in
stdenv.mkDerivation (finalAttrs: {

  pname = "kwm";
  version = "0.3.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "kewuaa";
    repo = "kwm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hX76wTHPTgg5RAHILfd3CjRKPlgAwGSK3lG82IFoUUs=";
  };

  zigDeps = zig.fetchDeps {
    inherit (finalAttrs) src pname version;
    fetchAll = true;
    hash = "sha256-Lz/Wcy40rxN81n/mBj4YJVbyGOolHzSFZMs93T1h0oQ=";
  };

  postConfigure = ''
    ln -s ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
    zig
  ];

  buildInputs = [
    fcft
    libxkbcommon
    pixman
    wayland
    wayland-scanner
    wayland-protocols
  ];

  zigBuildFlags = [
    "-Doptimize=ReleaseSafe"
    "-Dbackground=false"
    "-Dbar=true"
    "-Dkwim=true"
  ];

  postInstall =
    let
      desktopItem = makeDesktopItem {
        name = "kwm";
        desktopName = "KWM (River)";
        comment = finalAttrs.meta.description;
        exec = "${lib.getExe river} -c ${finalAttrs.meta.mainProgram}";
      };
    in
    ''
      install -Dm644 ${desktopItem}/share/applications/kwm.desktop -t $out/share/wayland-sessions/
    '';

  passthru = {
    providedSessions = [ "kwm" ];
    updateScript = nix-update-script { };
  };

  meta = {
    description = "DWM-like dynamic tiling window manager implementing the river-window-management-v1 protocol";
    changelog = "https://github.com/kewuaa/kwm/releases/tag/v${finalAttrs.src.tag}";
    homepage = "https://github.com/kewuaa/kwm";
    license = lib.licenses.gpl3Only;
    mainProgram = "kwm";
    inherit (zig.meta) platforms;
  };
})
