{
  copyDesktopItems,
  fetchFromGitHub,
  lib,
  libglvnd,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrender,
  libxt,
  makeDesktopItem,
  openssl,
  rustPlatform,
  vulkan-loader,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "steam-optionx";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "RoGreat";
    repo = "steam-optionx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IkfO7VOAYBF7hj2z0smcpXUSGI4Aol28oA1z4YB4P6U=";
  };

  cargoHash = "sha256-MmDIEMA0I9GC9v3Ytfajg9ydWSmgtnazF4/wR+OiG+8=";

  nativeBuildInputs = [
    copyDesktopItems
  ];

  buildInputs = [
    openssl
  ];

  postInstall = ''
    install -Dm444 assets/icon.svg $out/share/icons/hicolor/scalable/apps/steam_optionx.svg
  '';

  postFixup = ''
    patchelf $out/bin/steam-optionx --set-rpath ${
      lib.makeLibraryPath [
        libglvnd # libGL.so libEGL.so
        libx11 # libX11.so libX11-xcb.so
        libxcb # libxcb
        libxcursor # libXcursor.so
        libxi # libXi.so
        libxinerama # libXinerama.so
        libxkbcommon # libxkbcommon.so libxkbcommon-x11.so
        libxrender # libXrender.so
        libxt # libXt.so
        vulkan-loader # libvulkan.so
        wayland # libwayland-egl.so libwayland-client.so
      ]
    };
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "steam-optionx";
      desktopName = "Steam OptionX";
      icon = "steam_optionx";
      exec = "steam-optionx";
      comment = "Modify Steam launch options";
      categories = [ "Utility" ];
    })
  ];

  meta = {
    description = "Modify app launch options in Steam's config file";
    homepage = "https://github.com/RoGreat/steam-optionx";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "steam-optionx";
    platforms = lib.platforms.linux;
  };
})
