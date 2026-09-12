{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  pkg-config,
  zig_0_16,

  libxkbcommon,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

let
  zig = zig_0_16;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "kwim";
  version = "0.2.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "kewuaa";
    repo = "kwim";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ewg259zRCMGq75XXMmPqoFwD5NBEFXXsIj1rvMy31uw=";
  };

  zigDeps = zig.fetchDeps {
    inherit (finalAttrs) src pname version;
    fetchAll = true;
    hash = "sha256-rOZZu/Y/rZ7who3hl1qIBHXZtRP7s4FXo0+LNnM6dYo=";
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
    libxkbcommon
    wayland
    wayland-protocols
    wayland-scanner
  ];

  zigBuildFlags = [
    "-Doptimize=ReleaseSafe"
    "-Dbash-completion=true"
    "-Dzsh-completion=true"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Input manager for River, implementing the river-input-management-v1 protocol";
    homepage = "https://github.com/kewuaa/kwim";
    changelog = "https://github.com/kewuaa/kwim/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    mainProgram = "kwim";
    inherit (zig.meta) platforms;
  };
})
