{
  autoPatchelfHook,
  copyDesktopItems,
  fetchFromGitHub,
  lib,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "steam-optionx";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "RoGreat";
    repo = "steam-optionx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fbi4jbWvyuCZm7j6Lqcqui/OuBx4ZTwtAkilXu/U6vg=";
  };

  cargoHash = "sha256-51SBfow2+8OkjKj1qbMDdMI6PdDKyszpRqDtF1pcT1Y=";

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
    libx11
    libxcursor
    libxi
    libxkbcommon
    libxrandr
    wayland
  ];

  postInstall = ''
    install -Dm444 assets/icon.svg $out/share/icons/hicolor/scalable/apps/steam_optionx.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "steam-optionx";
      desktopName = "Steam OptionX";
      icon = "steam_optionx";
      exec = "steam-optionx";
      comment = "Modify Steam launch options";
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Modify app launch options in Steam's config file";
    homepage = "https://github.com/RoGreat/steam-optionx";
    changelog = "https://github.com/RoGreat/steam-optionx/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "steam-optionx";
    platforms = lib.platforms.linux;
  };
})
