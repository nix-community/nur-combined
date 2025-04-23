{ lib, appimageTools, fetchurl }:
let
  pname = "zen";
  version = "1.11.5b";

  src = fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
    hash = "sha256-RFVkUhXmRS/cbZPBaUwV+I5NtLJZYcltxFpygqdp9Vg=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/zen.desktop $out/share/applications/zen.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/128x128/apps/zen.png \
      $out/share/icons/hicolor/128x128/apps/zen.png
  '';

  extraPkgs = pkgs:[ pkgs.ffmpeg-headless ];

  meta = with lib; {
    description = "User-friendly, useful, mods that increase usability can be added from the zen-mods mod store, a customizable browser, features that can be searched for in a browser for the end user, easy to use thanks to the shortcut key assignment feature, theme-store, frequently used progressive web apps, add-on apps, websites can be easily accessed thanks to the sidebar feature, can be viewed as a mobile page. container, work spaces, zen-mods, window management by creating multiple tab sections in a window, sidebar feature.";
    homepage = "https://zen-browser.app/";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    hydraPlatforms = [ ];
    license = with licenses; [ mpl20 mit ];
  };
}
