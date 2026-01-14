{
  lib,
  mkWindowsAppNoCC,
  wine,
  fetchurl,
  makeDesktopItem,
  makeDesktopIcon,
  copyDesktopItems,
  copyDesktopIcons,
  p7zip,
  gawk,
  xorg,
  virtualDesktop ? false,
}:
# Based on AUR acroread-dc-wine (maintainer Smoolak), adapted for mkWindowsAppNoCC.
mkWindowsAppNoCC rec {
  inherit wine;

  pname = "adobe-acrobat-reader";
  version = "2025.1.20997";

  src = fetchurl {
    url = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2500120997/AcroRdrDC2500120997_en_US.exe";
    hash = "sha256-gznoj4yY9Fktz8LVWhjBwArUqSlQOUX9/r6ukojATG8=";
  };

  dontUnpack = true;
  wineArch = "win32";
  persistRegistry = false;
  persistRuntimeLayer = true;
  enableMonoBootPrompt = false;
  graphicsDriver = "auto";

  nativeBuildInputs = [
    copyDesktopItems
    copyDesktopIcons
  ];

  enabledWineSymlinks = {
    desktop = false;
  };

  fileMap = {
    "$HOME/.config/adobe-acrobat-reader/Local" = "drive_c/users/$USER/AppData/Local/Adobe";
    "$HOME/.config/adobe-acrobat-reader/LocalLow" = "drive_c/users/$USER/AppData/LocalLow/Adobe";
    "$HOME/.config/adobe-acrobat-reader/Roaming" = "drive_c/users/$USER/AppData/Roaming/Adobe";
  };

  regTweaks = fetchurl {
    url = "https://aur.archlinux.org/cgit/aur.git/plain/acroread-dc.reg?h=acroread-dc-wine";
    hash = "sha256-EXFuBh+altFKojYtrrviQkLi5LFCFeGo2VPhfNFlvj4=";
  };

  winAppInstall = ''
    export WINEDEBUG="-all"
    work="$(mktemp -d)"

    winetricks --unattended mspatcha >/dev/null 2>&1 || true
    winetricks --unattended riched20 >/dev/null 2>&1 || true
    winetricks --unattended vcrun2015 >/dev/null 2>&1 || true

    ${p7zip}/bin/7z x -y -o"$work" ${src} >/dev/null 2>&1 || true
    setup="$(find "$work" -maxdepth 2 -iname 'setup.exe' | head -n1)"
    if [ -n "$setup" ]; then
      $WINE "$setup" /sAll
      wineserver -w
    else
      echo "Acrobat setup.exe not found in extracted files" >&2
      exit 1
    fi

    regfile="$WINEPREFIX/drive_c/acroread-dc.reg"
    cp ${regTweaks} "$regfile"
    $WINE regedit "$($WINE winepath -w "$regfile")" >/dev/null 2>&1 || true
    wineserver -w

    winetricks --unattended win7 >/dev/null 2>&1 || true
  '';

  winAppRun = ''
    export WINEDEBUG="-all"
    reader="$WINEPREFIX/drive_c/Program Files (x86)/Adobe/Acrobat Reader DC/Reader/AcroRd32.exe"
    if [ ! -f "$reader" ]; then
      reader="$WINEPREFIX/drive_c/Program Files/Adobe/Acrobat Reader DC/Reader/AcroRd32.exe"
    fi
    if [ ! -f "$reader" ]; then
      echo "Adobe Acrobat Reader executable not found in Wine prefix" >&2
      exit 1
    fi

    if ${
      if virtualDesktop then "true" else "false"
    } && [ "''${ACROREAD_NO_VIRTUAL_DESKTOP:-0}" != "1" ]; then
      res="$(${xorg.xrandr}/bin/xrandr 2>/dev/null | ${gawk}/bin/awk '/\\*/ && $1 ~ /^[0-9]+x[0-9]+$/ {print $1; exit}')"
      if [ -z "$res" ]; then
        res="1920x1080"
      fi
      $WINE explorer /desktop=AcroRead,"$res" "$reader" "$ARGS"
    else
      $WINE reg add "HKCU\Software\Wine\X11 Driver" /v Decorated /t REG_SZ /d N /f
      $WINE "$reader" "$ARGS"
    fi
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Adobe Acrobat Reader DC";
      categories = [
        "Office"
        "Viewer"
      ];
      mimeTypes = [
        "application/pdf"
      ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;

    src = fetchurl {
      url = "https://web.archive.org/web/20260101142441if_/https://community.chocolatey.org/content/packageimages/adobereader.2025.1.20997.png";
      hash = "sha256-g6sgfVLDyTRTGLxx5/rYqBJT0cl+hjziPHI7/nr3Lt8=";
    };
  };

  meta = with lib; {
    description = "Adobe Acrobat Reader DC - PDF viewer (via Wine)";
    homepage = "https://www.adobe.com/products/reader.html";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "adobe-acrobat-reader";
  };
}
