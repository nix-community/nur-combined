{
  lib,
  stdenvNoCC,
  makeWrapper,
  wineWow64Packages,
  p7zip,
  imagemagick,
  makeDesktopItem,
  fetchzip,
}:

let
  desktopItem = makeDesktopItem {
    name = "notepad++";
    exec = "notepad++ %F";
    icon = "notepad++";
    desktopName = "Notepad++";
    comment = "Source code editor";
    categories = [ "Development" "TextEditor" ];
    terminal = false;
    type = "Application";
    startupWMClass = "notepad++.exe";
    startupNotify = true;
    mimeTypes = [ "text/plain" ];
  };
in
stdenvNoCC.mkDerivation rec {
  pname = "notepad++";
  version = "8.9.8";

  src = fetchzip {
    url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v${version}/npp.${version}.portable.x64.zip";
    hash = "sha256-PJXciUI7sMAWLwRlS4O9b5ULZlxGukuyB0REltXEkDc=";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper p7zip imagemagick ];

  passthru = { inherit desktopItem; };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/{notepad++,applications,icons/hicolor}}

    7z x $src/notepad++.exe
    for f in 256 128 64 48 32 16; do
      mkdir -p $out/share/icons/hicolor/''${f}x''${f}
    done
    cp .rsrc/ICON/4 $out/share/icons/hicolor/256x256/notepad++.png
    magick .rsrc/ICON/5.ico $out/share/icons/hicolor/128x128/notepad++.png
    magick .rsrc/ICON/6.ico $out/share/icons/hicolor/64x64/notepad++.png
    magick .rsrc/ICON/7.ico $out/share/icons/hicolor/48x48/notepad++.png
    magick .rsrc/ICON/8.ico $out/share/icons/hicolor/32x32/notepad++.png
    magick .rsrc/ICON/9.ico $out/share/icons/hicolor/16x16/notepad++.png

    # can't rely purely on $src due to needing to delete doLocalConf.xml
    cp -r $src/* $out/share/notepad++
    rm $out/share/notepad++/doLocalConf.xml

    makeWrapper ${wineWow64Packages.stable}/bin/wine $out/bin/notepad++ \
      --set WINEDEBUG "-all" \
      --set WINEDLLOVERRIDES "mscoree=d" \
      --run "export NPP_DIR=\''${XDG_DATA_HOME:-\$HOME/.local/share}/notepad++" \
      --run "mkdir -p \$NPP_DIR/{settings,wineprefix}" \
      --run "export WINEPREFIX=\$NPP_DIR/wineprefix" \
      --add-flags "$out/share/notepad++/notepad++.exe -settingsDir=\"Z:/\$NPP_DIR/settings\""

    cp ${desktopItem}/share/applications/*.desktop $out/share/applications/

    runHook postInstall
  '';

  meta = {
    description = "Source code editor for Windows (Wine wrapper)";
    homepage = "https://notepad-plus-plus.org";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    broken = stdenvNoCC.hostPlatform.isDarwin; # can it even ever work on macOS?
    mainProgram = "notepad++";
  };
}
