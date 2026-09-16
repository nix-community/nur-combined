{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,

  pkg-config,

  xclip,
  wl-clipboard,
  clipnotify,
}:
rustPlatform.buildRustPackage (finalAttrs: {

  pname = "linuxqq-clipsync";
  version = "0-unstable-2026-08-27";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "SHORiN-KiWATA";
    repo = "linuxqq-clipsync";
    rev = "39eee4a75d0bf58cf1b4a2c4185be515307d6137";
    hash = "sha256-gl10A/r6j1lYu74VudPAEs+CagjfZmvHZe9GS49QOWs=";
  };

  cargoHash = "sha256-x/kaA/HLGX2jO26rtnLhajT7IFpDXLn1ql/+oW6I1SE=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    xclip
    wl-clipboard
    clipnotify
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "通过同步 X11 和 Wayland 剪贴板的方式修复 Linuxqq 以 Wayland 运行时的剪贴板异常";
    homepage = "https://github.com/SHORiN-KiWATA/linuxqq-clipsync";
    license = lib.licenses.mit;
    mainProgram = "linuxqq-clipsync";
    platforms = lib.platforms.linux;
  };
})
