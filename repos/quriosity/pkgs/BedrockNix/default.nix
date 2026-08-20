{ lib, appimageTools, fetchurl, makeDesktopItem, nix-update-script }:

let
  pname = "BedrockOnLinux";
  version = "2.2.0";

  src = fetchurl {
    url = "https://github.com/Wyze3306/BedrockOnLinux/releases/download/v${version}/BedrockOnLinux-${version}-x86_64.AppImage";
    hash = "sha256-+vr3dHI+CtZnI8Pcv0rFKQUmPih5T7Z0u3dc0ixuCK0=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname} gui";
    icon = pname;
    desktopName = "BedrockOnLinux";
    genericName = "Minecraft Bedrock Launcher";
    comment = "Run Minecraft Bedrock (Windows GDK) on Linux, multiplayer included";
    categories = [ "Game" "ActionGame" ];
    keywords = [ "minecraft" "bedrock" "gdk" "wine" "proton" "mcbe" ];
    startupNotify = true;
    startupWMClass = "BedrockOnLinux";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
      webkitgtk_4_1
      gtk3
      libsoup_3
      glib-networking
      python3

      mesa
      libGL
      vulkan-loader
      libX11
      libXext
      libXrandr
      libXi
      libXcursor
      libXxf86vm
    ] ++ (with pkgs.pkgsi686Linux; [
      glibc
      mesa
      libGL
      libX11
      libXext
    ]);

  extraInstallCommands = ''
    install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop

    install -m 444 -D ${appimageContents}/usr/bin/data/icon.png \
      $out/share/icons/hicolor/256x256/apps/${pname}.png
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Run Minecraft Bedrock seamlessly on Linux";
    homepage = "https://github.com/Wyze3306/BedrockOnLinux";
    license = licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "BedrockOnLinux";
  };
}
