{
  lib,
  sources,
  version,
  appimageTools,
}:
appimageTools.wrapAppImage (finalAttrs: {
  pname = "waywallen";
  inherit version;

  src = appimageTools.extract {
    inherit (finalAttrs) pname version;
    inherit (sources) src;
  };

  extraInstallCommands = ''
    install -D ${finalAttrs.src}/org.waywallen.waywallen.desktop $out/share/applications/org.waywallen.waywallen.desktop

    mkdir -p $out/share/icons
    cp -r ${finalAttrs.src}/usr/share/icons/hicolor $out/share/icons
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
})
