{
  lib,
  sources,
  version,
  appimageTools,
}:
appimageTools.wrapType2 rec {
  inherit (sources) pname src;
  inherit version;

  extraInstallCommands =
    let
      appimageContents = appimageTools.extract { inherit pname version src; };
    in
    ''
      install -D ${appimageContents}/org.waywallen.waywallen.desktop $out/share/applications/org.waywallen.waywallen.desktop

      mkdir -p $out/share/icons
      cp -r ${appimageContents}/usr/share/icons/hicolor $out/share/icons
    '';

  meta = {
    description = "Wallpaper Manager for Linux";
    homepage = "https://github.com/waywallen/waywallen";
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "waywallen";
  };
}
