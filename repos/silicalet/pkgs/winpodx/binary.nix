{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "winpodx-bin";
  version = "0.10.4";
  src = fetchurl {
    url = "https://github.com/kernalix7/winpodx/releases/download/v${version}/winpodx-x86_64.AppImage";
    hash = "sha256-Ce5SLIBudyZavA8Q1ww2oiCxuY+W03D8sCYWYZhuy60=";
  };
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    desktopFile="$(find ${contents} -path '*/share/applications/*.desktop' -print -quit)"
    if [ -n "$desktopFile" ]; then
      install -Dm444 "$desktopFile" "$out/share/applications/winpodx.desktop"
      sed -i -e 's|^Exec=.*|Exec=winpodx|' "$out/share/applications/winpodx.desktop"
    fi

    if [ -d ${contents}/usr/share/icons ]; then
      cp -r ${contents}/usr/share/icons "$out/share/"
    fi
  '';

  meta = {
    description = "Windows app integration for Linux desktop";
    homepage = "https://github.com/kernalix7/winpodx";
    changelog = "https://github.com/kernalix7/winpodx/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "winpodx";
    platforms = [ "x86_64-linux" ];
  };
}
