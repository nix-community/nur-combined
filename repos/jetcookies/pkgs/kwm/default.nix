# Refer: https://github.com/srcres258/nur-packages/blob/main/pkgs/kwm/default.nix
{
  lib,
  stdenv,
  fetchFromGitHub,

  zig_0_16,
  pkg-config,
  wayland-scanner,

  wayland,
  wayland-protocols,
  libxkbcommon,
  pixman,
  fcft,
}:
stdenv.mkDerivation (finalAttrs: {

  pname = "kwm";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "kewuaa";
    repo = "kwm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-hX76wTHPTgg5RAHILfd3CjRKPlgAwGSK3lG82IFoUUs=";
  };

  nativeBuildInputs = [
    zig_0_16
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
    pixman
    fcft
  ];

  zigDeps = zig_0_16.fetchDeps {
    inherit (finalAttrs) src pname version;
    fetchAll = true;
    hash = "sha256-Lz/Wcy40rxN81n/mBj4YJVbyGOolHzSFZMs93T1h0oQ=";
  };

  postConfigure = ''
    ln -s ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  zigBuildFlags = [
    "-Doptimize=ReleaseSafe"
    "-Dbackground=false"
    "-Dbar=true"
    "-Dkwim=true"
  ];

  dontUseZigCheck = true;

  meta = {
    changelog = "https://github.com/kewuaa/kwm/releases/tag/v${finalAttrs.version}";
    description = "DWM-like dynamic tiling window manager implementing the river-window-management-v1 protocol";
    homepage = "https://github.com/kewuaa/kwm";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "kwm";
  };
})
