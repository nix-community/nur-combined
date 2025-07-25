{
  autoPatchelfHook,
  copyDesktopItems,
  fetchFromGitHub,
  lib,
  libGL,
  libxkbcommon,
  makeDesktopItem,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  wayland,
  xorg,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "steam-optionx";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "RoGreat";
    repo = "steam-optionx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1rglQDXM14xUvFdJAlwU+S3sOq0zi0nTt4CxqU+TipI=";
  };

  cargoHash = "sha256-Va3oU9Vx8GIYvNWZ8Sooz62DziHc+VXzvd9I5CkO1r4=";

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    pkg-config
  ];

  buildInputs = [
    openssl
    stdenv.cc.cc.libgcc or null
  ];

  runtimeDependencies = [
    libGL
    libxkbcommon
    wayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
  ];

  postInstall = ''
    install -m 444 -D assets/icon.svg $out/share/icons/hicolor/scalable/apps/steam_optionx.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "steam-optionx";
      desktopName = "Steam OptionX";
      icon = "steam_optionx";
      exec = finalAttrs.meta.mainProgram;
      comment = finalAttrs.meta.description;
      categories = [ "Game" ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Configure Steam apps launch options";
    homepage = "https://github.com/RoGreat/steam-optionx";
    changelog = "https://github.com/RoGreat/steam-optionx/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "steam-optionx";
    platforms = lib.platforms.linux;
  };
})
