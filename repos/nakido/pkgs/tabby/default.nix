{
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
}:

appimageTools.wrapAppImage rec {
  meta = with lib; {
    description = "A terminal for a more modern age";
    homepage = "https://github.com/Eugeny/tabby";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "tabby";
  };

  pname = "tabby";
  version = "1.0.215";

  src = appimageTools.extract {
    inherit pname version;
    src = fetchurl {
      url = "https://github.com/Eugeny/tabby/releases/download/v${version}/tabby-${version}-linux-x64.AppImage";
      sha256 = "sha256-7/p/kQYX8ydMOznl0ti0VgnU7c5jLp9IonI99zjeN+w=";
    };
  };

  extraInstallCommands = ''
    install -Dm444 ${src}/tabby.desktop -t $out/share/applications
    install -Dm444 ${src}/tabby.png -t $out/share/pixmaps

    substituteInPlace $out/share/applications/tabby.desktop \
      --replace-fail "Exec=AppRun" "Exec=tabby"

    . ${makeWrapper}/nix-support/setup-hook
    wrapProgram $out/bin/tabby \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
  '';
}